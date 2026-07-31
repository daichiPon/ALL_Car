# All Car 🚗

すべての車を見て、探して、友達とシェアできるカーカタログ＆コミュニティアプリ。

---

## 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [主な機能](#2-主な機能)
3. [画面構成](#3-画面構成)
4. [データモデル](#4-データモデル)
5. [デザイン仕様](#5-デザイン仕様)
6. [技術構成](#6-技術構成)
7. [Swift 側の構成案](#7-swift-側の構成案)
8. [Cloudflare バックエンド構成案](#8-cloudflare-バックエンド構成案)
9. [DB スキーマ案（D1 / SQL）](#9-db-スキーマ案d1--sql)
10. [API エンドポイント案](#10-api-エンドポイント案)
11. [ロードマップ](#11-ロードマップ)
12. [注意点・課題](#12-注意点課題)

---

## 1. プロジェクト概要

**All Car** は「すべての車が見られて、コミュニケーションもできる」ことをコンセプトにしたモバイルアプリ。

- すべての車のカタログ（新車価格・性能を掲載）を閲覧できる
- 気になった車をお気に入り登録して一覧管理できる
- メーカー・車種・ミッションなどを **選択して** 探せる
- 車ごとのコメント、友達とのトーク（シェア）ができる
- 最近の車ニュースが表示される

**実装方針**：iOS ネイティブ（Swift / SwiftUI）＋ Cloudflare（Workers / D1 / R2 など）で構築する。
本ドキュメントは、その仕様・設計・ロードマップをまとめた実装計画書。

---

## 2. 主な機能

### ホーム
- 最近の車ニュースを一覧表示
- 「注目の新車」を横スクロールカードで表示
- カードから車詳細へ遷移

### さがす（選択式検索）
- 入力式ではなく **ドロップダウンで選択して検索**
  - メーカー
  - 車種（選んだメーカーに連動して候補が絞られる）
  - ミッション（AT / MT）
- 「この条件でさがす」で検索を実行
- 検索後は該当ブランドが自動展開され、**ブランド → 車種** のネストで結果表示
- 選択した車種はハイライト表示
- 車種タップで詳細へ

### お気に入り
- 各所のハートで登録／解除
- お気に入りだけを一覧表示（空状態のガイドあり）

### トーク
- 友達リスト（未読バッジ・オンライン表示）
- チャット画面（メッセージ送信）
- 車詳細の共有ボタンから、車カードをトークにシェア

### 車詳細
- 新車価格
- 性能ゲージ（最高出力）＋スペック（駆動 / ミッション / エンジン or パワートレイン / 燃費 or 航続）
- お気に入り登録
- コメント欄（閲覧・投稿）
- トークへのシェア

---

## 3. 画面構成

```
App
├─ ホーム (Home)
│   ├─ ニュース一覧
│   └─ 注目の新車（横スクロール）
├─ さがす (Search)
│   ├─ 選択式検索パネル（メーカー / 車種 / ミッション）
│   └─ 検索結果：ブランド ▸ 車種（アコーディオン）
├─ お気に入り (Favorites)
│   └─ お気に入り車の一覧
├─ トーク (Talk)
│   ├─ 友達リスト
│   └─ チャット（車カードのシェア対応）
└─ 車詳細 (Car Detail) ※オーバーレイ
    ├─ 価格・性能ゲージ・スペック
    ├─ お気に入り登録
    ├─ コメント
    └─ シェア
```

下部タブ：`ホーム / さがす / お気に入り / トーク`

---

## 4. データモデル

### 車 (car)

| フィールド | 型 | 例 | 説明 |
| --- | --- | --- | --- |
| `id` | number | `2` | 一意 ID |
| `maker` | string | `"Honda"` | メーカー名 |
| `name` | string | `"シビック TYPE R"` | 車種名 |
| `body` | string | `"スポーツ"` | ボディタイプ |
| `drive` | string | `"FF"` | 駆動方式（FF/FR/4WD/AWD） |
| `trans` | string | `"6MT"` | ミッション表記 |
| `transType` | string | `"MT"` | 絞り込み用（AT/MT） |
| `power` | number | `330` | 最高出力（PS） |
| `disp` | string | `"2.0L Turbo"` | エンジン／パワートレイン |
| `fuel` | string | `"12.5"` | 燃費(km/L) または 航続距離 |
| `price` | number | `499` | 新車価格（万円） |
| `color` | string | `"#FF5A4D"` | 表示アクセント色 |
| `ev` | boolean | `false` | EV かどうか |
| `tag` | string | `"ホットハッチ"` | キャッチ |

### その他
- **コメント**：`{ user, text, time }`（車 ID ごとに配列）
- **友達**：`{ name, last, unread, active }`
- **チャット**：`{ me, text, who?, car? }`
- **ニュース**：`{ id, cat, title, time, src }`
- **ブランドバッジ**：`{ color, mono }`（頭文字＋ブランドカラー）

---

## 5. デザイン仕様

- **テーマ**：ダーク背景 ＋ ロイヤルブルーのアクセント
- **アクセントカラー**：`#3B5BF5`
- **背景 / パネル**：`#0E1116` / `#171B22` / `#1E232C`
- **さがす画面**：ダーク背景上に白のブランドカード
  - ブランドバッジ（頭文字＋ブランドカラーの円）
  - 展開時はカードヘッダーがブルー反転、車種は淡いグレーの行
- **フォント**
  - 見出し／ワードマーク：Oswald（コンデンス）
  - 本文／UI：Inter
  - 数値（価格・スペック）：Space Mono（デジタル計器風）
- **モチーフ**：計器盤（ダッシュボード）。性能ゲージをシグネチャ要素に

---

## 6. 技術構成

```
┌──────────────┐     HTTPS / WebSocket     ┌───────────────────────────┐
│   iOS App     │ ───────────────────────▶ │      Cloudflare            │
│  (SwiftUI)    │                          │  Workers / D1 / R2 / KV /  │
│               │ ◀─────────────────────── │  Durable Objects / Queues  │
└──────────────┘        JSON / WS           └───────────────────────────┘
```

- **フロントエンド**：Swift / SwiftUI（iOS ネイティブ）
- **バックエンド**：Cloudflare（Workers + D1 + R2 + KV + Durable Objects など）

> Swift は iOS（および macOS / iPadOS）向けのネイティブ実装です。Android にも対応する場合は、別途 Kotlin での実装や共通化の検討が必要になります（当面 iOS に集中する前提）。

---

## 7. Swift 側の構成案

### 技術・ライブラリ
| 用途 | 採用 |
| --- | --- |
| UI | **SwiftUI**（宣言的 UI） |
| アーキテクチャ | MVVM（`@Observable` / `ObservableObject`） |
| 画面遷移 | `NavigationStack` / `TabView` |
| 非同期・通信 | Swift Concurrency（`async/await`）＋ `URLSession` |
| WebSocket | `URLSessionWebSocketTask`（トーク用） |
| 画像読み込み | `AsyncImage`（標準）または Nuke / Kingfisher |
| ローカルキャッシュ | **SwiftData**（iOS 17+）または Core Data |
| 認証情報の保管 | Keychain（トークンの安全な保存） |
| 依存管理 | Swift Package Manager (SPM) |

### ディレクトリ構成（例）
```
AllCar/
├─ AllCarApp.swift        # エントリポイント（@main）
├─ Core/                  # テーマ・定数・共通ビュー
├─ Models/                # Car, User, Comment, Message ...
├─ Services/              # APIClient, ChatSocket, AuthService
├─ ViewModels/            # SearchViewModel, FavoritesViewModel ...
└─ Features/
   ├─ Home/               # ニュース・注目の新車
   ├─ Search/             # 選択式検索・ブランド/車種ネスト
   ├─ Favorites/          # お気に入り
   ├─ Talk/               # トーク・シェア
   └─ CarDetail/          # 詳細・コメント
```

### 画面・UI と SwiftUI 実装の対応
| 画面 / UI 要素 | SwiftUI での実装 |
| --- | --- |
| 下部タブ | `TabView` |
| さがすの選択式ドロップダウン | `Menu` / `Picker` |
| ブランド → 車種のネスト | `DisclosureGroup`（または `List` のセクション展開） |
| 車詳細（オーバーレイ） | `.sheet` / `NavigationStack` の push |
| コメント・トーク入力 | `TextField` ＋ 送信ボタン |
| お気に入りハート | `@State` トグル ＋ API 同期 |
| 性能ゲージ | `Canvas` または `Shape`（`trim` で円弧描画） |

> SwiftUI は「状態から UI を組み立てる」宣言的スタイルなので、各画面（Home / Search / Favorites / Talk / CarDetail）を上記の `Features/` 配下にそのまま対応させて実装できる。

---

## 8. Cloudflare バックエンド構成案

| 役割 | Cloudflare プロダクト | 用途 |
| --- | --- | --- |
| API / バックエンド | **Workers** | REST API、認証、ビジネスロジック |
| リレーショナル DB | **D1**（SQLite） | 車両・ユーザー・お気に入り・コメント |
| オブジェクトストレージ | **R2** | 車の画像、ブランドロゴ、ユーザーアバター |
| 画像最適化 | **Cloudflare Images**（任意） | サムネイル生成・配信 |
| キャッシュ / セッション | **KV** | 一覧キャッシュ、トークン、設定 |
| リアルタイムチャット | **Durable Objects** | WebSocket でトーク部屋を管理 |
| バッチ / 取り込み | **Queues + Cron Triggers** | ニュース取り込み、車両データ同期 |
| Web 版ホスティング | **Pages**（任意） | 管理画面や Web 版を用意する場合 |
| （将来）レコメンド等 | **Workers AI**（任意） | おすすめ車種の提示など |

- 「オブジェクト DB / オブジェクト保存」は **R2**（S3 互換のオブジェクトストレージ）を想定。画像・ファイル系はここに保存し、URL を D1 に持たせる形が定番です。
- リアルタイムなトークは、部屋（room）ごとに **Durable Object** を割り当てて WebSocket を捌くのが Cloudflare での定番パターンです。

> Cloudflare の各プロダクトは進化が速いので、実装前に最新の公式ドキュメントで料金・制限（D1 の容量やリクエスト上限、Durable Objects の課金など）を確認してください。

---

## 9. DB スキーマ案（D1 / SQL）

```sql
-- メーカー
CREATE TABLE makers (
  id           INTEGER PRIMARY KEY,
  name         TEXT NOT NULL,
  badge_color  TEXT,
  logo_key     TEXT           -- R2 のキー
);

-- 車
CREATE TABLE cars (
  id           INTEGER PRIMARY KEY,
  maker_id     INTEGER NOT NULL REFERENCES makers(id),
  name         TEXT NOT NULL,
  body         TEXT,          -- 軽/セダン/SUV...
  drive        TEXT,          -- FF/FR/4WD/AWD
  trans        TEXT,          -- 6MT/CVT/AT...
  trans_type   TEXT,          -- AT/MT（絞り込み用）
  power        INTEGER,       -- PS
  displacement TEXT,          -- 2.0L Turbo など
  fuel         TEXT,          -- 燃費 or 航続
  price        INTEGER,       -- 万円
  is_ev        INTEGER DEFAULT 0,
  tag          TEXT,
  image_key    TEXT,          -- R2 のキー
  created_at   TEXT DEFAULT (datetime('now'))
);

-- ユーザー
CREATE TABLE users (
  id          INTEGER PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  avatar_key  TEXT,
  created_at  TEXT DEFAULT (datetime('now'))
);

-- お気に入り
CREATE TABLE favorites (
  user_id     INTEGER NOT NULL REFERENCES users(id),
  car_id      INTEGER NOT NULL REFERENCES cars(id),
  created_at  TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, car_id)
);

-- コメント
CREATE TABLE comments (
  id          INTEGER PRIMARY KEY,
  car_id      INTEGER NOT NULL REFERENCES cars(id),
  user_id     INTEGER NOT NULL REFERENCES users(id),
  body        TEXT NOT NULL,
  created_at  TEXT DEFAULT (datetime('now'))
);

-- 友達関係
CREATE TABLE friendships (
  user_id    INTEGER NOT NULL REFERENCES users(id),
  friend_id  INTEGER NOT NULL REFERENCES users(id),
  status     TEXT DEFAULT 'accepted',  -- pending/accepted
  PRIMARY KEY (user_id, friend_id)
);

-- トーク（メッセージ）
CREATE TABLE messages (
  id          INTEGER PRIMARY KEY,
  room_id     TEXT NOT NULL,        -- DM や部屋の識別子
  sender_id   INTEGER NOT NULL REFERENCES users(id),
  body        TEXT,
  car_id      INTEGER REFERENCES cars(id),  -- 車をシェアした場合
  created_at  TEXT DEFAULT (datetime('now'))
);

-- ニュース
CREATE TABLE news (
  id           INTEGER PRIMARY KEY,
  category     TEXT,
  title        TEXT NOT NULL,
  body         TEXT,
  source       TEXT,
  published_at TEXT
);
```

---

## 10. API エンドポイント案

Cloudflare Workers 上の REST + WebSocket（イメージ）。

```
# 車・メーカー
GET    /api/makers
GET    /api/cars?maker=&model=&trans=&body=&page=
GET    /api/cars/:id

# お気に入り
GET    /api/favorites
POST   /api/favorites        { car_id }
DELETE /api/favorites/:car_id

# コメント
GET    /api/cars/:id/comments
POST   /api/cars/:id/comments  { body }

# ニュース
GET    /api/news

# 認証
POST   /api/auth/register
POST   /api/auth/login
GET    /api/me

# トーク（Durable Objects / WebSocket）
GET    /api/rooms                     # 参加中の部屋一覧
WS     /api/chat/:roomId              # リアルタイム接続
POST   /api/chat/:roomId/share        { car_id }   # 車をシェア
```

---

## 11. ロードマップ

**フェーズ 1：基盤**
- [ ] Cloudflare Workers + D1 の初期化、スキーマ投入
- [ ] 車両データの投入（データソースの選定）
- [ ] `GET /cars`・`GET /cars/:id`・`GET /makers` の API
- [ ] SwiftUI で一覧・詳細・選択式検索を実装し API 接続

**フェーズ 2：ユーザー機能**
- [ ] 認証（登録／ログイン）
- [ ] お気に入り（登録・一覧の永続化）
- [ ] コメント（投稿・表示）
- [ ] R2 に画像を保存し、詳細に実車画像を表示

**フェーズ 3：コミュニケーション**
- [ ] 友達機能
- [ ] Durable Objects でリアルタイムトーク
- [ ] トークへの車シェア
- [ ] プッシュ通知

**フェーズ 4：仕上げ**
- [ ] ニュース取り込み（Queues + Cron）
- [ ] ブランドロゴの正式対応（許諾 or 差し替え）
- [ ] 検索の高速化（KV キャッシュ）
- [ ] ストア申請

---

## 12. 注意点・課題

- **車両データの入手先**：「すべての車」を自前で集め続けるのは負担が大きい。新車・中古車のデータ提供サービス／API との契約、または対象を絞って（例：国産新車のみ）開始するのが現実的。
- **ブランドロゴの商標**：当面は頭文字バッジで代用。実ロゴを使う場合は各メーカーの利用許諾が必要。
- **リアルタイムトーク**：アカウント・友達関係・メッセージ保存・通知が必要。Cloudflare では Durable Objects で実現できるが、設計と課金の確認を。
- **車種とグレード**：現状の設計は「1 車種＝1 レコード」。グレード（AT/MT 違いなど）を扱うなら、車種の下にグレードをネストする構造に拡張する。

---

### 成果物
- `README.md` … 本ドキュメント

## テストユーザ
```
• test@example.com / secret123（テスト太郎）
• hanako@example.com / secret456（花子)
```