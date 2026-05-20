import 'dart:convert';

class TitleResponse {
  final List<String> titles;

  TitleResponse({required this.titles});

  // JSONからパースするメソッド
  factory TitleResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List?;

    if (content == null || content.isEmpty) {
      return TitleResponse(titles: []);
    }

    final textContent = content.firstWhere(
      (item) => item['type'] == 'text',
      orElse: () => null,
    );

    if (textContent == null) {
      return TitleResponse(titles: []);
    }

    final text = textContent['text'] as String;
    final titles = _parseTitle(text);

    return TitleResponse(titles: titles);
  }

  // APIレスポンスからタイトルを抽出
  static List<String> _parseTitle(String text) {
    final List<String> titles = [];

    // 「タイトルX: ...」形式で抽出
    final pattern = RegExp(r'タイトル\d+:\s*(.+?)(?=\n|$)');
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      final title = match.group(1)?.trim() ?? '';
      if (title.isNotEmpty) {
        titles.add(title);
      }
    }

    return titles;
  }

  // JSON化するメソッド（必要に応じて使用）
  Map<String, dynamic> toJson() {
    return {
      'titles': titles,
    };
  }
}
