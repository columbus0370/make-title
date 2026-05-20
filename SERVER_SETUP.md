# プロキシサーバーのセットアップ

このアプリは CORSエラーを回避するため、ローカルプロキシサーバーを使用しています。

## セットアップ手順

### 1. APIキーを設定

`server.dart` の 4 行目を編集:

```dart
const String anthropicApiKey = 'sk-ant-YOUR_API_KEY_HERE';
```

↓ 以下に置き換え:

```dart
const String anthropicApiKey = 'sk-ant-xxxxx...'; // あなたのAPIキーを貼り付け
```

APIキーは [console.anthropic.com](https://console.anthropic.com) から取得できます。

### 2. プロキシサーバーを起動

ターミナルで以下を実行（プロジェクトルート）:

```bash
dart server.dart
```

または（Pubが設定されている場合）:

```bash
dart pub get
dart server.dart
```

サーバーが起動すると:
```
サーバー起動: http://localhost:8080
エンドポイント: POST /api/generate-titles
```

### 3. Flutterアプリを起動

別のターミナルで:

```bash
flutter run -d web-server
```

ブラウザが `http://localhost:55088` で開きます。

## アーキテクチャ

```
ブラウザ (localhost:55088)
    ↓
[プロキシサーバー (localhost:8080)]  ← APIキーを安全に管理
    ↓
Anthropic API (api.anthropic.com)
```

## セキュリティメモ

- **APIキーはサーバー側のみで保持** → ブラウザの開発者ツールで見えない
- **CORS対応** → ブラウザのクロスオリジンリクエストが許可される
- **本番環境** → バックエンドサーバーを別ホストで運用してください

## トラブルシューティング

### 「通信エラー」が出る場合
- プロキシサーバーが起動しているか確認: `http://localhost:8080/health` にアクセス
- ファイアウォール設定を確認

### 「APIキーが設定されていません」エラー
- `server.dart` の 4 行目に正しいAPIキーを設定しているか確認

### 「API Keyが無効です」エラー
- APIキーが有効か確認（Anthropic コンソールで確認）
- キーが削除・失効していないか確認
