import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  final String title;
  final int index;

  const TitleCard({
    Key? key,
    required this.title,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイプバッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getTitleTypeColor(index),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTitleType(index),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // タイトルテキスト
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // コピーボタン
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.content_copy, size: 16),
                label: const Text('コピー'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleType(int index) {
    const types = [
      'YouTube風',
      'ブログ風',
      'SNS風',
      '学習系',
      'ニュース風',
    ];
    return types[index % types.length];
  }

  Color _getTitleTypeColor(int index) {
    const colors = [
      Colors.red,      // YouTube
      Colors.blue,     // Blog
      Colors.purple,   // SNS
      Colors.green,    // Learning
      Colors.orange,   // News
    ];
    return colors[index % colors.length];
  }

  void _copyToClipboard(BuildContext context) {
    // 今後の実装（clipboard_manager等を使用）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('タイトルをコピーしました'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
