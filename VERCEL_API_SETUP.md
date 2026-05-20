# Vercel API セットアップガイド

## 概要
make-title プロジェクトは Flutter Web フロントエンド + Node.js バックエンド（Vercel Serverless Functions）で構成されています。

---

## 1. プロジェクト構成

### ディレクトリ構成
```
make-title/
├── api/                    # Vercel Serverless Functions
│   └── generate-titles.js  # Claude API プロキシエンドポイント
├── build/web/              # Flutter Web ビルド出力（静的ファイル）
├── lib/                     # Flutter アプリコード
│   ├── constants/
│   │   └── api_constants.dart
│   ├── services/
│   │   └── claude_service.dart
│   └── main.dart
├── package.json            # Node.js 依存パッケージ
├── vercel.json             # Vercel 設定
└── pubspec.yaml            # Flutter 依存パッケージ
```

---

## 2. Vercel の環境変数設定

### 必須環境変数
- **ANTHROPIC_API_KEY**: Anthropic API キー（`sk-ant-` で始まる）
  - 設定場所: Vercel ダッシュボード → Settings → Environment Variables
  - 環境: Production, Preview, Development に設定
  - 参考: https://console.anthropic.com/account/keys

---

## 3. API エンドポイント

### エンドポイント
- **URL**: `/api/generate-titles`（相対パス）
- **メソッド**: POST
- **ホスト**: https://make-title-[random].vercel.app（Vercel が自動生成）

### リクエスト形式
```json
{
  "messages": [
    {
      "role": "user",
      "content": "ユーザーの入力内容"
    }
  ]
}
```

### レスポンス形式
Claude API の標準レスポンス形式（Anthropic SDK）
```json
{
  "id": "msg_...",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Claude の応答"
    }
  ],
  "model": "claude-opus-4-7",
  "stop_reason": "end_turn",
  "usage": {
    "input_tokens": 123,
    "output_tokens": 456
  }
}
```

---

## 4. バックエンド実装詳細

### ファイル: `/api/generate-titles.js`

#### 主要な処理フロー
1. CORS ヘッダーの設定
2. HTTP メソッドの検証（POST のみ受け付け）
3. リクエストボディの検証（messages 配列が必須）
4. 環境変数の確認（ANTHROPIC_API_KEY）
5. Claude API への呼び出し
6. エラーハンドリングとレスポンス返却

#### 使用モデル
- **現在**: `claude-opus-4-7`
- **変更方法**: 
  - `api/generate-titles.js` の 38 行目を修正
  - または環境変数 `CLAUDE_MODEL` を追加

#### リクエスト設定
```javascript
const response = await client.messages.create({
  model: 'claude-opus-4-7',      // 使用モデル
  max_tokens: 1024,               // 最大出力トークン数
  messages: messages,             // ユーザーのメッセージ
});
```

---

## 5. フロントエンド実装詳細

### ファイル: `/lib/constants/api_constants.dart`

#### API エンドポイント設定
```dart
static const String apiBaseUrl = '/api/generate-titles';
```

#### クエリプロンプト
`getTitleGenerationPrompt(userInput)` メソッドで、以下の 5 種類のタイトルを生成するプロンプトを構築：
1. YouTube 風（視聴欲をそそるタイトル）
2. ブログ風（SEO 対応）
3. SNS 風（短くて目を引く）
4. 学習系（わかりやすく学習欲をそそる）
5. ニュース風（インパクトのあるタイトル）

### ファイル: `/lib/services/claude_service.dart`

#### API 呼び出し処理
```dart
static Future<TitleResponse> generateTitles(String userInput) async {
  final response = await http.post(
    Uri.parse(ApiConstants.apiBaseUrl),
    headers: {
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'model': ApiConstants.model,
      'max_tokens': 1024,
      'messages': [
        {
          'role': 'user',
          'content': ApiConstants.getTitleGenerationPrompt(userInput),
        }
      ],
    }),
  );
  
  return TitleResponse.fromJson(jsonDecode(response.body));
}
```

#### エラーハンドリング
- 401: APIキーが無効
- 429: レート制限に達した
- 400: クライアントエラー
- その他: サーバーエラー

---

## 6. パッケージ依存関係

### Node.js パッケージ (`package.json`)
```json
{
  "dependencies": {
    "@anthropic-ai/sdk": "^0.28.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "vercel": "^33.0.0"
  }
}
```

### Flutter パッケージ (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  cupertino_icons: ^1.0.8
```

---

## 7. Vercel 設定ファイル

### ファイル: `vercel.json`
```json
{
  "outputDirectory": "build/web",
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "/api/:path*"
    },
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

#### 設定の説明
- `outputDirectory`: Flutter Web ビルド出力ディレクトリ
- `rewrites[0]`: API ルートは `/api/:path*` にマップ
- `rewrites[1]`: SPA フォールバック（すべてのリクエストを `index.html` にマップ）

---

## 8. デプロイフロー

### ステップ 1: ローカルで Flutter Web をビルド
```bash
flutter build web --release
```

### ステップ 2: Git にコミット
```bash
git add .
git commit -m "Update Flutter web build"
git push origin main
```

### ステップ 3: Vercel が自動デプロイ
- GitHub webhook によりデプロイが自動開始
- `build/web` の静的ファイルがホストされる
- `/api/generate-titles` が Serverless Function として実行

---

## 9. トラブルシューティング

### エラー 1: `invalid x-api-key`
**原因**: ANTHROPIC_API_KEY が無効または設定されていない

**解決**:
1. Vercel の Environment Variables を確認
2. https://console.anthropic.com/account/keys で API キーが有効か確認
3. 新しい API キーを生成して再設定

### エラー 2: `model: [model-name] not found`
**原因**: 指定したモデルが存在しないまたはアクセス権がない

**解決**:
1. `api/generate-titles.js` のモデル名を確認
2. 有効なモデル名を使用（例: `claude-opus-4-7`）

### エラー 3: `flutter: command not found`
**原因**: ビルド済みファイル（`build/web`）がコミットされていない

**解決**:
1. ローカルで `flutter build web --release` を実行
2. `build/web` ディレクトリを Git にコミット
3. `git push origin main`

---

## 10. 監視・ログ

### Vercel ダッシュボード確認箇所
- **Deployments**: デプロイ状態
- **Logs**: ビルドログとランタイムログ
- **Environment Variables**: 環境変数設定確認
- **Settings**: プロジェクト設定

### API エラーの確認
1. ブラウザの開発者ツール（F12）→ Console
2. Vercel ダッシュボード → Logs → Function Logs
3. 関連するリクエストの詳細ログを確認

---

## 11. セキュリティ考慮事項

- ✅ API キーは環境変数で管理（リポジトリに含まない）
- ✅ CORS ヘッダー設定済み（必要に応じてカスタマイズ可能）
- ✅ POST リクエストのみ受け付け（GET/OPTIONS を制限）
- ⚠️ フロントエンド側で直接 API キーを使用しない

---

## 12. 参考リンク

- Vercel ダッシュボード: https://vercel.com/dashboard
- GitHub リポジトリ: https://github.com/columbus0370/make-title
- Anthropic API ドキュメント: https://docs.anthropic.com
- Anthropic SDK (Node.js): https://github.com/anthropics/anthropic-sdk-python
- Vercel Serverless Functions: https://vercel.com/docs/functions

---

## 13. 更新履歴

- **2026-05-20**: 初版作成
  - Vercel デプロイ完了
  - Node.js バックエンド実装
  - Flutter Web フロントエンド実装
  - モデル: `claude-opus-4-7`

