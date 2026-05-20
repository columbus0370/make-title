import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final String anthropicApiKey = 'sk-ant-YOUR_API_KEY_HERE';
const String anthropicApiBaseUrl = 'https://api.anthropic.com/v1/messages';
const String anthropicVersion = '2024-06-01';

void main() async {
  final server = await HttpServer.bind('localhost', 8080);

  print('サーバー起動: http://localhost:8080');
  print('エンドポイント: POST /api/generate-titles');
  print('ヘルスチェック: GET /health');

  await for (final request in server) {
    _handleRequest(request);
  }
}

// リクエスト処理
void _handleRequest(HttpRequest request) async {
  // CORS ヘッダー設定
  request.response.headers.add('Access-Control-Allow-Origin', '*');
  request.response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
  request.response.headers.add('Content-Type', 'application/json; charset=utf-8');

  // OPTIONS リクエスト（プリフライト）対応
  if (request.method == 'OPTIONS') {
    request.response.statusCode = 200;
    await request.response.close();
    return;
  }

  if (request.uri.path == '/health' && request.method == 'GET') {
    request.response.write(jsonEncode({'status': 'ok'}));
    await request.response.close();
    return;
  }

  if (request.uri.path == '/api/generate-titles' && request.method == 'POST') {
    await _generateTitles(request);
    return;
  }

  request.response.statusCode = 404;
  request.response.write(jsonEncode({'error': 'Not found'}));
  await request.response.close();
}

// タイトル生成エンドポイント
Future<void> _generateTitles(HttpRequest request) async {
  try {
    final body = await utf8.decodeStream(request);

    if (anthropicApiKey.isEmpty || anthropicApiKey == 'sk-ant-YOUR_API_KEY_HERE') {
      request.response.statusCode = 400;
      request.response.write(jsonEncode({'error': 'APIキーが設定されていません。server.dartを確認してください。'}));
      await request.response.close();
      return;
    }

    // Anthropic API にフォワード
    final response = await http.post(
      Uri.parse(anthropicApiBaseUrl),
      headers: {
        'x-api-key': anthropicApiKey,
        'anthropic-version': anthropicVersion,
        'content-type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 30));

    request.response.statusCode = response.statusCode;
    request.response.write(response.body);
    await request.response.close();
  } catch (e) {
    request.response.statusCode = 500;
    request.response.write(jsonEncode({'error': e.toString()}));
    await request.response.close();
  }
}
