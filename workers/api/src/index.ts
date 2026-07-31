// All Car REST API（README 10章）
//
//   GET  /api/makers                 メーカー一覧
//   GET  /api/cars?maker=&model=&trans=   車一覧（選択式検索）
//   GET  /api/cars/:id               車詳細
//   GET  /api/cars/:id/comments      コメント一覧
//   POST /api/cars/:id/comments      { body } コメント投稿（ログイン時は本人名義、未ログインはゲスト）
//   GET  /api/news                   ニュース一覧
//   POST /api/auth/register          { name, email, password } → { token, user }
//   POST /api/auth/login             { email, password } → { token, user }
//   GET  /api/me                     Authorization: Bearer <token> → { user }
//
// データソースは D1 (allcar-db)。スキーマは schema.sql（README 9章）。
// パスワードは PBKDF2(SHA-256, 10万回) でハッシュ化し、セッショントークンを sessions に保存する。

export interface Env {
  DB: D1Database;
}

// MARK: 認証ヘルパー

const toHex = (bytes: Uint8Array) =>
  Array.from(bytes).map((b) => b.toString(16).padStart(2, "0")).join("");

async function derive(password: string, salt: Uint8Array): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(password), "PBKDF2", false, ["deriveBits"]
  );
  const bits = await crypto.subtle.deriveBits(
    { name: "PBKDF2", hash: "SHA-256", salt, iterations: 100_000 }, key, 256
  );
  return toHex(new Uint8Array(bits));
}

async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  return `${toHex(salt)}:${await derive(password, salt)}`;
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [saltHex, expected] = stored.split(":");
  if (!saltHex || !expected) return false;
  const salt = new Uint8Array(saltHex.match(/.{2}/g)!.map((h) => parseInt(h, 16)));
  return (await derive(password, salt)) === expected;
}

function newToken(): string {
  return toHex(crypto.getRandomValues(new Uint8Array(32)));
}

interface UserRow { id: number; name: string; email: string }

const userJSON = (u: UserRow) => ({ id: u.id, name: u.name, email: u.email });

/** Authorization: Bearer <token> からユーザーを引く（無効なら null） */
async function authedUser(request: Request, env: Env): Promise<UserRow | null> {
  const auth = request.headers.get("Authorization");
  const token = auth?.match(/^Bearer\s+(.+)$/)?.[1];
  if (!token) return null;
  const row = await env.DB
    .prepare(`
      SELECT users.id, users.name, users.email
      FROM sessions JOIN users ON users.id = sessions.user_id
      WHERE sessions.token = ?
    `)
    .bind(token)
    .first<UserRow>();
  return row ?? null;
}

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });

/// D1 の行を iOS 側 `Car` と同じ形の JSON に変換する
const carJSON = (r: any) => ({
  id: r.id,
  maker: r.maker,
  name: r.name,
  body: r.body,
  drive: r.drive,
  trans: r.trans,
  transType: r.trans_type,
  power: r.power,
  disp: r.displacement,
  fuel: r.fuel,
  price: r.price,
  color: r.color,
  ev: r.is_ev === 1,
  tag: r.tag,
  imageKey: r.image_key,
});

const CAR_SELECT = `
  SELECT cars.*, makers.name AS maker
  FROM cars JOIN makers ON makers.id = cars.maker_id
`;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    try {
      // ユーザー登録
      if (path === "/api/auth/register" && request.method === "POST") {
        const body = (await request.json()) as { name?: string; email?: string; password?: string };
        const name = body.name?.trim();
        const email = body.email?.trim().toLowerCase();
        const password = body.password ?? "";
        if (!name || !email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
          return json({ error: "名前と正しいメールアドレスを入力してください" }, 400);
        }
        if (password.length < 6) {
          return json({ error: "パスワードは6文字以上にしてください" }, 400);
        }
        const existing = await env.DB.prepare("SELECT id FROM users WHERE email = ?").bind(email).first();
        if (existing) return json({ error: "このメールアドレスは登録済みです" }, 409);

        const passwordHash = await hashPassword(password);
        const inserted = await env.DB
          .prepare("INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?) RETURNING id, name, email")
          .bind(name, email, passwordHash)
          .first<UserRow>();
        const token = newToken();
        await env.DB.prepare("INSERT INTO sessions (token, user_id) VALUES (?, ?)").bind(token, inserted!.id).run();
        return json({ token, user: userJSON(inserted!) }, 201);
      }

      // ログイン
      if (path === "/api/auth/login" && request.method === "POST") {
        const body = (await request.json()) as { email?: string; password?: string };
        const email = body.email?.trim().toLowerCase();
        const row = email
          ? await env.DB
              .prepare("SELECT id, name, email, password_hash FROM users WHERE email = ?")
              .bind(email)
              .first<UserRow & { password_hash: string | null }>()
          : null;
        if (!row?.password_hash || !(await verifyPassword(body.password ?? "", row.password_hash))) {
          return json({ error: "メールアドレスまたはパスワードが違います" }, 401);
        }
        const token = newToken();
        await env.DB.prepare("INSERT INTO sessions (token, user_id) VALUES (?, ?)").bind(token, row.id).run();
        return json({ token, user: userJSON(row) });
      }

      // 自分の情報
      if (path === "/api/me" && request.method === "GET") {
        const user = await authedUser(request, env);
        return user ? json({ user: userJSON(user) }) : json({ error: "unauthorized" }, 401);
      }

      // APNs デバイストークン登録（README フェーズ3: プッシュ通知）
      if (path === "/api/devices" && request.method === "POST") {
        const user = await authedUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const body = (await request.json()) as { token?: string };
        const deviceToken = body.token?.trim();
        if (!deviceToken) return json({ error: "token is required" }, 400);
        await env.DB
          .prepare("INSERT OR REPLACE INTO device_tokens (token, user_id, updated_at) VALUES (?, ?, datetime('now'))")
          .bind(deviceToken, user.id)
          .run();
        return json({ ok: true }, 201);
      }

      // 友達一覧（README フェーズ3: friendships）
      if (path === "/api/friends" && request.method === "GET") {
        const user = await authedUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const { results } = await env.DB
          .prepare(`
            SELECT users.id, users.name, users.email
            FROM friendships JOIN users ON users.id = friendships.friend_id
            WHERE friendships.user_id = ? AND friendships.status = 'accepted'
            ORDER BY users.name
          `)
          .bind(user.id)
          .all();
        return json(results.map((r: any) => userJSON(r)));
      }

      // 友達追加（メールアドレス指定・双方向に accepted で登録）
      if (path === "/api/friends" && request.method === "POST") {
        const user = await authedUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const body = (await request.json()) as { email?: string };
        const email = body.email?.trim().toLowerCase();
        if (!email) return json({ error: "メールアドレスを入力してください" }, 400);
        const target = await env.DB
          .prepare("SELECT id, name, email FROM users WHERE email = ?")
          .bind(email)
          .first<UserRow>();
        if (!target) return json({ error: "このメールアドレスのユーザーが見つかりません" }, 404);
        if (target.id === user.id) return json({ error: "自分自身は追加できません" }, 400);
        await env.DB.batch([
          env.DB.prepare("INSERT OR IGNORE INTO friendships (user_id, friend_id, status) VALUES (?, ?, 'accepted')").bind(user.id, target.id),
          env.DB.prepare("INSERT OR IGNORE INTO friendships (user_id, friend_id, status) VALUES (?, ?, 'accepted')").bind(target.id, user.id),
        ]);
        return json(userJSON(target), 201);
      }

      // メーカー一覧
      if (path === "/api/makers" && request.method === "GET") {
        const { results } = await env.DB.prepare(
          "SELECT id, name, badge_color FROM makers ORDER BY name"
        ).all();
        return json(results.map((r: any) => ({ id: r.id, name: r.name, badgeColor: r.badge_color })));
      }

      // 車一覧（選択式検索: maker / model / trans）
      if (path === "/api/cars" && request.method === "GET") {
        const conditions: string[] = [];
        const bindings: unknown[] = [];
        const maker = url.searchParams.get("maker");
        const model = url.searchParams.get("model");
        const trans = url.searchParams.get("trans");
        if (maker) { conditions.push("makers.name = ?"); bindings.push(maker); }
        if (model) { conditions.push("cars.name = ?"); bindings.push(model); }
        if (trans) { conditions.push("cars.trans_type = ?"); bindings.push(trans); }
        const where = conditions.length ? ` WHERE ${conditions.join(" AND ")}` : "";
        const { results } = await env.DB
          .prepare(`${CAR_SELECT}${where} ORDER BY cars.id`)
          .bind(...bindings)
          .all();
        return json(results.map(carJSON));
      }

      // 車詳細
      const carMatch = path.match(/^\/api\/cars\/(\d+)$/);
      if (carMatch && request.method === "GET") {
        const row = await env.DB
          .prepare(`${CAR_SELECT} WHERE cars.id = ?`)
          .bind(Number(carMatch[1]))
          .first();
        return row ? json(carJSON(row)) : json({ error: "not found" }, 404);
      }

      // コメント
      const commentsMatch = path.match(/^\/api\/cars\/(\d+)\/comments$/);
      if (commentsMatch) {
        const carID = Number(commentsMatch[1]);
        if (request.method === "GET") {
          const { results } = await env.DB
            .prepare(`
              SELECT comments.body, comments.created_at, users.name AS user
              FROM comments JOIN users ON users.id = comments.user_id
              WHERE comments.car_id = ? ORDER BY comments.created_at DESC, comments.id DESC
            `)
            .bind(carID)
            .all();
          return json(results.map((r: any) => ({ user: r.user, text: r.body, time: r.created_at })));
        }
        if (request.method === "POST") {
          const body = (await request.json()) as { body?: string };
          const text = body.body?.trim();
          if (!text) return json({ error: "body is required" }, 400);
          // ログイン済みなら本人名義、未ログインはゲストユーザー (id=1)
          const user = await authedUser(request, env);
          await env.DB
            .prepare("INSERT INTO comments (car_id, user_id, body) VALUES (?, ?, ?)")
            .bind(carID, user?.id ?? 1, text)
            .run();
          return json({ ok: true }, 201);
        }
      }

      // ニュース
      if (path === "/api/news" && request.method === "GET") {
        const { results } = await env.DB
          .prepare("SELECT id, category, title, source, published_at FROM news ORDER BY id")
          .all();
        return json(results.map((r: any) => ({
          id: r.id, cat: r.category, title: r.title, time: r.published_at, src: r.source,
        })));
      }

      return json({ error: "not found" }, 404);
    } catch (e: any) {
      return json({ error: e.message ?? "internal error" }, 500);
    }
  },
};
