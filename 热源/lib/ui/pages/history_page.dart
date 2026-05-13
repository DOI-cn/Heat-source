import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final mockHistory = [
      ('2026-05-13 12:10', '午餐', 512.4),
      ('2026-05-13 08:05', '早餐', 386.7),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: mockHistory.isEmpty
            ? const Center(child: Text('暂无记录'))
            : ListView.separated(
                itemCount: mockHistory.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = mockHistory[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant_menu_rounded),
                    title: Text(item.$2),
                    subtitle: Text(item.$1),
                    trailing: Text('${item.$3.toStringAsFixed(1)} kcal'),
                  );
                },
              ),
      ),
    );
  }
}
