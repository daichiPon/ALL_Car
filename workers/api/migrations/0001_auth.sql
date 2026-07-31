-- 認証（README フェーズ2）: パスワードハッシュとセッション
ALTER TABLE users ADD COLUMN password_hash TEXT;

CREATE TABLE IF NOT EXISTS sessions (
  token       TEXT PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id),
  created_at  TEXT DEFAULT (datetime('now'))
);
