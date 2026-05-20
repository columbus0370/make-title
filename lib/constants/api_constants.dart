class ApiConstants {
  // Vercel Serverless Functions のエンドポイント
  // APIキーはサーバー側で安全に管理
  static const String apiBaseUrl = '/api/generate-titles';

  // APIキーはサーバー側で管理（クライアント側では不要）
  static const String apiKey = '';

  // モデル指定
  static const String model = 'claude-sonnet-4-20250514';

  // APIバージョン
  static const String anthropicVersion = '2024-06-01';

  // タイムアウト（秒）
  static const int requestTimeout = 30;

  // タイトル生成時のプロンプトテンプレート
  static String getTitleGenerationPrompt(String userInput) {
    return '''ユーザーが入力した内容を元に、魅力的で、クリックしたくなるタイトルを5個生成してください。

タイトルジャンル：
1. YouTube風（視聴欲をそそるタイトル）
2. ブログ風（SEO対応、詳細感のあるタイトル）
3. SNS風（短くて目を引くタイトル）
4. 学習系（わかりやすく、学習欲をそそるタイトル）
5. ニュース風（インパクトのあるタイトル）

ユーザー入力内容：
「$userInput」

以下の形式で5個のタイトルを出力してください。タイトルのみで、説明は不要です。
タイトル1: [1番目のタイトル]
タイトル2: [2番目のタイトル]
タイトル3: [3番目のタイトル]
タイトル4: [4番目のタイトル]
タイトル5: [5番目のタイトル]''';
  }
}
