// All Car トーク API（README 10章）
//
//   WS   /api/chat/:roomId?token=<セッショントークン>   リアルタイム接続
//   GET  /api/chat/:roomId/history                      メッセージ履歴（要 Authorization）
//   POST /api/chat/:roomId/share                        { car_id } 車をシェア（要 Authorization）
//   GET  /api/rooms                                     参加中の部屋一覧（友達機能導入後に実装）
//
// 認証: allcar-api が発行したセッショントークン（D1 の sessions テーブル）を
// Worker 側で検証し、ユーザー情報を Durable Object へ渡す。
// 送信者はトークンから特定した認証ユーザー（"user-<id>"）になる。
// 部屋ごとに Durable Object (ChatRoom) を 1 つ割り当て、
// WebSocket Hibernation API で接続を管理、履歴は DO 内蔵の SQLite に保存する。

import { DurableObject } from "cloudflare:workers";
import { sendPush } from "./apns";

export interface Env {
  CHAT_ROOM: DurableObjectNamespace;
  DB: D1Database;
  // APNs（apns.ts / wrangler.jsonc 参照。シークレット未設定なら通知はスキップ）
  APNS_ENV?: string;
  APNS_TOPIC?: string;
  APNS_TEAM_ID?: string;
  APNS_KEY_ID?: string;
  APNS_PRIVATE_KEY?: string;
}

interface WireMessage {
  id: string;
  sender: string;      // "user-<id>"
  senderName?: string; // 表示名
  text?: string;
  carID?: number;
  ts: number;
}

interface AuthedUser {
  id: number;
  name: string;
}

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });

/** セッショントークンからユーザーを引く（allcar-api と同じ sessions テーブル） */
async function userFromToken(token: string, env: Env): Promise<AuthedUser | null> {
  const row = await env.DB
    .prepare(`
      SELECT users.id, users.name
      FROM sessions JOIN users ON users.id = sessions.user_id
      WHERE sessions.token = ?
    `)
    .bind(token)
    .first<AuthedUser>();
  return row ?? null;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    const match = url.pathname.match(/^\/api\/chat\/([^/]+)(\/[^/]*)?$/);
    if (match) {
      // 認証: WebSocket は ?token=、REST は Authorization: Bearer
      const token =
        url.searchParams.get("token") ??
        request.headers.get("Authorization")?.match(/^Bearer\s+(.+)$/)?.[1];
      const user = token ? await userFromToken(token, env) : null;
      if (!user) return json({ error: "unauthorized" }, 401);

      // 部屋 ID は friendships ベースの "dm-<小さいユーザーID>-<大きいユーザーID>"。
      // 本人が参加者でない部屋（旧 "dm-<名前>" 形式を含む）は拒否する。
      const roomId = decodeURIComponent(match[1]);
      const dm = roomId.match(/^dm-(\d+)-(\d+)$/);
      if (!dm || (user.id !== Number(dm[1]) && user.id !== Number(dm[2]))) {
        return json({ error: "forbidden: not a participant of this room" }, 403);
      }

      // 検証済みユーザー情報をヘッダーで DO へ渡す（日本語名は URL エンコード）
      const headers = new Headers(request.headers);
      headers.set("X-User-ID", String(user.id));
      headers.set("X-User-Name", encodeURIComponent(user.name));

      const stub = env.CHAT_ROOM.get(env.CHAT_ROOM.idFromName(roomId));
      return stub.fetch(new Request(request, { headers }));
    }

    if (url.pathname === "/api/rooms") {
      // 友達機能を導入するまでは空配列を返すスタブ
      return json({ rooms: [] });
    }

    return json({ error: "not found" }, 404);
  },
};

export class ChatRoom extends DurableObject<Env> {
  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env);
    ctx.storage.sql.exec(`
      CREATE TABLE IF NOT EXISTS messages (
        id     TEXT PRIMARY KEY,
        sender TEXT NOT NULL,
        text   TEXT,
        car_id INTEGER,
        ts     INTEGER NOT NULL
      )
    `);
    // 既存部屋への追加カラム（存在する場合は無視）
    try {
      ctx.storage.sql.exec("ALTER TABLE messages ADD COLUMN sender_name TEXT");
    } catch {}
  }

  private userFrom(request: Request): AuthedUser {
    return {
      id: Number(request.headers.get("X-User-ID") ?? 0),
      name: decodeURIComponent(request.headers.get("X-User-Name") ?? "unknown"),
    };
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const sub = url.pathname.replace(/^\/api\/chat\/[^/]+/, "") || "/";
    const user = this.userFrom(request);

    // プッシュ通知の宛先解決用に、部屋の参加者（dm-<a>-<b>）を保存しておく
    const dm = url.pathname.match(/^\/api\/chat\/dm-(\d+)-(\d+)/);
    if (dm) {
      await this.ctx.storage.put("participants", [Number(dm[1]), Number(dm[2])]);
    }

    // WebSocket 接続
    if (sub === "/") {
      if (request.headers.get("Upgrade")?.toLowerCase() !== "websocket") {
        return json({ error: "expected websocket upgrade" }, 426);
      }
      const pair = new WebSocketPair();
      // Hibernation API: 接続にユーザー情報を紐づけて保持する
      this.ctx.acceptWebSocket(pair[1]);
      pair[1].serializeAttachment(user);
      pair[1].send(JSON.stringify({ type: "history", messages: this.history() }));
      return new Response(null, { status: 101, webSocket: pair[0] });
    }

    if (sub === "/history" && request.method === "GET") {
      return json({ type: "history", messages: this.history() });
    }

    if (sub === "/share" && request.method === "POST") {
      const body = (await request.json()) as { car_id?: number; text?: string };
      if (typeof body.car_id !== "number") {
        return json({ error: "car_id is required" }, 400);
      }
      const message: WireMessage = {
        id: crypto.randomUUID(),
        sender: `user-${user.id}`,
        senderName: user.name,
        text: body.text,
        carID: body.car_id,
        ts: Date.now(),
      };
      this.persist(message);
      this.broadcast(message);
      await this.notifyRecipient(message, user.id);
      return json({ ok: true, message });
    }

    return json({ error: "not found" }, 404);
  }

  // MARK: WebSocket (Hibernation API)

  async webSocketMessage(ws: WebSocket, raw: string | ArrayBuffer) {
    let incoming: Partial<WireMessage> & { type?: string };
    try {
      incoming = JSON.parse(typeof raw === "string" ? raw : new TextDecoder().decode(raw));
    } catch {
      ws.send(JSON.stringify({ type: "error", error: "invalid json" }));
      return;
    }
    if (incoming.type !== "message") {
      ws.send(JSON.stringify({ type: "error", error: "expected {type:'message', text?, carID?}" }));
      return;
    }
    if (!incoming.text && typeof incoming.carID !== "number") return;

    // 送信者はクライアントの申告ではなく、接続時に検証したユーザーで決める
    const user = ws.deserializeAttachment() as AuthedUser;
    const message: WireMessage = {
      id: incoming.id ?? crypto.randomUUID(),
      sender: `user-${user.id}`,
      senderName: user.name,
      text: incoming.text,
      carID: incoming.carID,
      ts: Date.now(),
    };
    this.persist(message);
    this.broadcast(message);
    await this.notifyRecipient(message, user.id);
  }

  /// 相手が接続していなければ APNs で通知する（README フェーズ3: プッシュ通知）。
  private async notifyRecipient(m: WireMessage, senderID: number) {
    const participants = (await this.ctx.storage.get<number[]>("participants")) ?? [];
    const recipient = participants.find((p) => p !== senderID);
    if (!recipient) return;

    // 相手がこの部屋に接続中（画面を開いている）なら通知しない
    const connected = this.ctx.getWebSockets().some((ws) => {
      try {
        return (ws.deserializeAttachment() as AuthedUser | null)?.id === recipient;
      } catch {
        return false;
      }
    });
    if (connected) return;

    await sendPush(this.env, recipient, {
      title: m.senderName ?? "新着メッセージ",
      body: m.text ?? "🚗 車がシェアされました",
      senderUserID: senderID,
    });
  }

  async webSocketClose(ws: WebSocket, code: number) {
    ws.close(code, "closed");
  }

  // MARK: 履歴・配信

  private history(limit = 100): WireMessage[] {
    const rows = this.ctx.storage.sql
      .exec("SELECT id, sender, sender_name, text, car_id, ts FROM messages ORDER BY ts DESC, rowid DESC LIMIT ?", limit)
      .toArray()
      .reverse();
    return rows.map((r: any) => ({
      id: r.id,
      sender: r.sender,
      senderName: r.sender_name ?? undefined,
      text: r.text ?? undefined,
      carID: r.car_id ?? undefined,
      ts: r.ts,
    }));
  }

  private persist(m: WireMessage) {
    this.ctx.storage.sql.exec(
      "INSERT OR IGNORE INTO messages (id, sender, sender_name, text, car_id, ts) VALUES (?, ?, ?, ?, ?, ?)",
      m.id, m.sender, m.senderName ?? null, m.text ?? null, m.carID ?? null, m.ts
    );
  }

  private broadcast(m: WireMessage) {
    const payload = JSON.stringify({ type: "message", message: m });
    for (const ws of this.ctx.getWebSockets()) {
      try {
        ws.send(payload);
      } catch {
        // 切断済みソケットは無視
      }
    }
  }
}
