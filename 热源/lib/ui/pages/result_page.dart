import 'package:flutter/material.dart';

import '../widgets/primary_action_button.dart';
import 'history_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  static const routeName = '/result';

  @override
  Widget build(BuildContext context) {
    const mockItems = [
      ('米饭', 180.0, 1.16),
      ('鸡胸肉', 120.0, 1.65),
      ('西兰花', 90.0, 0.34),
    ];

    final total = mockItems
        .map((item) => item.$2 * item.$3)
        .fold<double>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('识别结果')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '识别明细（Mock）',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: mockItems.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = mockItems[index];
                  final itemCalorie = item.$2 * item.$3;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.$1),
                    subtitle: Text('${item.$2.toStringAsFixed(0)} g'),
                    trailing: Text('${itemCalorie.toStringAsFixed(1)} kcal'),
                  );
                },
              ),
            ),
            Text(
              '总热量：${total.toStringAsFixed(1)} kcal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            PrimaryActionButton(
              label: '保存并查看历史',
              icon: Icons.save_rounded,
              onPressed: () {
                Navigator.of(context).pushNamed(HistoryPage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
