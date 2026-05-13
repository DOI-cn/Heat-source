import 'package:flutter/material.dart';

import '../widgets/primary_action_button.dart';
import 'history_page.dart';
import 'result_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热量识别'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '拍照识别热量',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Day1 骨架版：首页先打通入口，后续接相机/相册能力。'),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: '拍照/上传（Mock）',
              icon: Icons.camera_alt_rounded,
              onPressed: () {
                Navigator.of(context).pushNamed(ResultPage.routeName);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(HistoryPage.routeName);
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('查看历史记录'),
            ),
          ],
        ),
      ),
    );
  }
}
