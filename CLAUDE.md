# make_title - プロジェクト引継ぎ情報

## 概要

Claude API を使って入力テキストから5種類のタイトルを生成する Flutter Web アプリ。
Claude API の学習目的で作成。

## アーキテクチャ

```
Flutter Web アプリ (ブラウザ)
    ↓ POST http://localhost:8080/api/generate-titles
Dart プロキシサーバー (server.dart)   ← APIキーをここで管理
    ↓ POST https://api.anthropic.com/v1/messages
Anthropic API (Claude)
```

Web ブラウザから直接 Anthropic API を叩くと CORS エラーになるため、
ローカルの Dart サーバーを中継役として使う構成。

## ファイル構成

```
make-title/
├── server.dart                        # プロキシサーバー（APIキーはここに書く）
├── lib/
│   ├── main.dart                      # アプリエントリーポイント
│   ├── constants/
│   │   └── api_constants.dart         # APIエンドポイント・モデル・プロンプト定義
│   ├── models/
│   │   └── title_response.dart        # APIレスポンスのパース
│   ├── screens/
│   │   └── home_screen.dart           # メイン画面UI
│   ├── services/
│   │   └── claude_service.dart        # HTTPリクエスト処理
│   └── widgets/
│       └── title_card.dart            # タイトル表示カード
├── pubspec.yaml                       # 依存関係（http: ^1.1.0 を使用）
└── SERVER_SETUP.md                    # サーバー起動手順
```

## APIキーの設定

`server.dart` の1行目を実際のキーに書き換える：

```dart
// server.dart 5行目
final String anthropicApiKey = 'sk-ant-YOUR_API_KEY_HERE';
//                              ↑ ここを実際のAPIキーに置き換える
```

APIキーの取得先: https://console.anthropic.com

**重要: APIキーを書き換えた server.dart は絶対に git commit しない。**
`.gitignore` に `server.dart` を追加することを推奨。

## 起動方法

ターミナルを2つ開いて実行する。

**ターミナル①: プロキシサーバー起動**
```bash
cd D:\src\projects\make-title
dart pub get
dart server.dart
```
→ `サーバー起動: http://localhost:8080` と表示されれば OK

**ターミナル②: Flutter アプリ起動**
```bash
cd D:\src\projects\make-title
flutter run -d chrome
```

ヘルスチェック: http://localhost:8080/health にアクセスして `{"status":"ok"}` が返れば正常。

## 使用モデル

`lib/constants/api_constants.dart` で指定：
```dart
static const String model = 'claude-sonnet-4-20250514';
```

モデルを変更したい場合はここを編集する。

## 生成するタイトルの種類

プロンプトは `lib/constants/api_constants.dart` の `getTitleGenerationPrompt()` に定義：

1. YouTube風（視聴欲をそそるタイトル）
2. ブログ風（SEO対応）
3. SNS風（短くて目を引く）
4. 学習系（わかりやすく学習欲をそそる）
5. ニュース風（インパクト重視）

## Gitブランチ状況

| ブランチ | 内容 |
|---|---|
| `main` | 元のコード（環境変数でAPIキー読み込み） |
| `claude/push-make-title-github-jOmcB` | 修正済み（ハードコード方式・バグ修正） |

ローカルで使う場合は修正済みブランチを取り込む：
```bash
git fetch origin
git merge origin/claude/push-make-title-github-jOmcB
```

## これまでの修正内容

`server.dart` を2箇所修正済み（`claude/push-make-title-github-jOmcB` ブランチ）：

1. **APIキー読み込み方式をハードコードに変更**
   - 変更前: `Platform.environment['ANTHROPIC_API_KEY'] ?? ''`（環境変数）
   - 変更後: `'sk-ant-YOUR_API_KEY_HERE'`（直接書き込み）

2. **空チェックのバグを修正**
   - 変更前: `if (anthropicApiKey == 'sk-ant-YOUR_API_KEY_HERE')` ← 環境変数が空でも絶対falseになるバグ
   - 変更後: `if (anthropicApiKey.isEmpty || anthropicApiKey == 'sk-ant-YOUR_API_KEY_HERE')`

## 依存パッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0        # HTTP通信に使用
```
