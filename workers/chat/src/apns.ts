// APNs (Apple Push Notification service) への送信。
//
// トークンベース認証（.p8 キー / ES256 JWT）を使う。
// シークレット（APNS_TEAM_ID / APNS_KEY_ID / APNS_PRIVATE_KEY）が未設定の間は
// 送信をスキップするので、キーなしでもチャット自体は動作する。

export interface ApnsEnv {
  DB: D1Database;
  APNS_ENV?: string;      // "sandbox" | "production"
  APNS_TOPIC?: string;    // アプリの Bundle ID
  APNS_TEAM_ID?: string;
  APNS_KEY_ID?: string;
  APNS_PRIVATE_KEY?: string; // .p8 ファイルの中身（PEM）
}

const b64url = (data: Uint8Array | string) => {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
};

function pemToDer(pem: string): Uint8Array {
  const body = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const bin = atob(body);
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

// JWT は約 45 分キャッシュする（APNs の要件: 20〜60 分ごとに再生成）
let cachedJWT: { token: string; issuedAt: number } | null = null;

async function apnsJWT(env: ApnsEnv): Promise<string | null> {
  if (!env.APNS_TEAM_ID || !env.APNS_KEY_ID || !env.APNS_PRIVATE_KEY) return null;

  const now = Math.floor(Date.now() / 1000);
  if (cachedJWT && now - cachedJWT.issuedAt < 45 * 60) return cachedJWT.token;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(env.APNS_PRIVATE_KEY),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"]
  );
  const header = b64url(JSON.stringify({ alg: "ES256", kid: env.APNS_KEY_ID }));
  const payload = b64url(JSON.stringify({ iss: env.APNS_TEAM_ID, iat: now }));
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(`${header}.${payload}`)
  );
  const token = `${header}.${payload}.${b64url(new Uint8Array(signature))}`;
  cachedJWT = { token, issuedAt: now };
  return token;
}

export interface PushContent {
  title: string;
  body: string;
  senderUserID: number;
}

/// 指定ユーザーの全デバイスへ通知を送る。無効になったトークンは削除する。
export async function sendPush(env: ApnsEnv, userID: number, content: PushContent): Promise<void> {
  const jwt = await apnsJWT(env);
  if (!jwt || !env.APNS_TOPIC) return; // キー未設定: スキップ

  const { results } = await env.DB
    .prepare("SELECT token FROM device_tokens WHERE user_id = ?")
    .bind(userID)
    .all();
  if (results.length === 0) return;

  const host = env.APNS_ENV === "production"
    ? "https://api.push.apple.com"
    : "https://api.sandbox.push.apple.com";

  const payload = JSON.stringify({
    aps: {
      alert: { title: content.title, body: content.body },
      sound: "default",
    },
    senderUserID: content.senderUserID,
  });

  for (const row of results as { token: string }[]) {
    try {
      const res = await fetch(`${host}/3/device/${row.token}`, {
        method: "POST",
        headers: {
          authorization: `bearer ${jwt}`,
          "apns-topic": env.APNS_TOPIC,
          "apns-push-type": "alert",
          "apns-priority": "10",
        },
        body: payload,
      });
      if (res.status === 400 || res.status === 410) {
        const reason = ((await res.json()) as { reason?: string }).reason;
        if (reason === "BadDeviceToken" || reason === "Unregistered" || reason === "ExpiredToken") {
          await env.DB.prepare("DELETE FROM device_tokens WHERE token = ?").bind(row.token).run();
        }
      }
    } catch {
      // 個々の送信失敗はメッセージ配信に影響させない
    }
  }
}
