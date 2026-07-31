-- All Car D1 スキーマ（README 9章）
-- `wrangler d1 execute allcar-db --remote --file=schema.sql`

-- メーカー
CREATE TABLE IF NOT EXISTS makers (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  badge_color  TEXT,
  logo_key     TEXT           -- R2 のキー
);

-- 車
CREATE TABLE IF NOT EXISTS cars (
  id           INTEGER PRIMARY KEY,
  maker_id     INTEGER NOT NULL REFERENCES makers(id),
  name         TEXT NOT NULL,
  body         TEXT,          -- 軽/セダン/SUV...
  drive        TEXT,          -- FF/FR/4WD/AWD...
  trans        TEXT,          -- 6MT/CVT/AT...
  trans_type   TEXT,          -- AT/MT（絞り込み用）
  power        INTEGER,       -- PS
  displacement TEXT,          -- 2.0L Turbo など
  fuel         TEXT,          -- 燃費 or 航続
  price        INTEGER,       -- 万円
  is_ev        INTEGER DEFAULT 0,
  tag          TEXT,
  color        TEXT,          -- 表示アクセント色 (README 4章)
  image_key    TEXT,          -- R2 のキー
  created_at   TEXT DEFAULT (datetime('now'))
);

-- ユーザー
CREATE TABLE IF NOT EXISTS users (
  id          INTEGER PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  avatar_key  TEXT,
  created_at  TEXT DEFAULT (datetime('now'))
);

-- お気に入り
CREATE TABLE IF NOT EXISTS favorites (
  user_id     INTEGER NOT NULL REFERENCES users(id),
  car_id      INTEGER NOT NULL REFERENCES cars(id),
  created_at  TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, car_id)
);

-- コメント
CREATE TABLE IF NOT EXISTS comments (
  id          INTEGER PRIMARY KEY,
  car_id      INTEGER NOT NULL REFERENCES cars(id),
  user_id     INTEGER NOT NULL REFERENCES users(id),
  body        TEXT NOT NULL,
  created_at  TEXT DEFAULT (datetime('now'))
);

-- 友達関係
CREATE TABLE IF NOT EXISTS friendships (
  user_id    INTEGER NOT NULL REFERENCES users(id),
  friend_id  INTEGER NOT NULL REFERENCES users(id),
  status     TEXT DEFAULT 'accepted',  -- pending/accepted
  PRIMARY KEY (user_id, friend_id)
);

-- トーク（メッセージ）: リアルタイム配信は Durable Objects、恒久保存はここ（フェーズ3）
CREATE TABLE IF NOT EXISTS messages (
  id          INTEGER PRIMARY KEY,
  room_id     TEXT NOT NULL,
  sender_id   INTEGER NOT NULL REFERENCES users(id),
  body        TEXT,
  car_id      INTEGER REFERENCES cars(id),
  created_at  TEXT DEFAULT (datetime('now'))
);

-- ニュース
CREATE TABLE IF NOT EXISTS news (
  id           INTEGER PRIMARY KEY,
  category     TEXT,
  title        TEXT NOT NULL,
  body         TEXT,
  source       TEXT,
  published_at TEXT
);
