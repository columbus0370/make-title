import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import '../models/title_response.dart';

class ClaudeService {
  // ローカルプロキシサーバー経由でClaudeにリクエストを送信
  static Future<TitleResponse> generateTitles(String userInput) async {
    if (userInput.isEmpty) {
      throw Exception('入力が空です');
    }

    try {
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
      ).timeout(
        const Duration(seconds: ApiConstants.requestTimeout),
        onTimeout: () => throw Exception('リクエストがタイムアウトしました'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TitleResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('APIキーが無効です。server.dartを確認してください。');
      } else if (response.statusCode == 429) {
        throw Exception('APIレート制限に達しました。少し待ってから再度お試しください。');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'クライアントエラー');
      } else {
        throw Exception('エラーが発生しました。ステータス: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('通信エラー（サーバーが起動していますか？）: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
