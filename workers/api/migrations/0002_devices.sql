-- プッシュ通知（README フェーズ3）: APNs デバイストークン
CREATE TABLE IF NOT EXISTS device_tokens (
  token       TEXT PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id),
  updated_at  TEXT DEFAULT (datetime('now'))
);
