import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/primary_action_button.dart';
import 'history_page.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null) return;
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        ResultPage.routeName,
        arguments: file.path,
      );
    } on Exception {
      if (!mounted) return;
      final msg = source == ImageSource.camera ? '无法打开相机，请检查权限设置' : '无法访问相册，请检查权限设置';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(
            label: '重试',
            onPressed: () => _pickImage(source),
          ),
        ),
      );
    }
  }

  void _showPicker() {
    showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('拍照'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('从相册选择'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('取消'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    ).then((source) {
      if (source != null) _pickImage(source);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('热量识别'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).pushNamed(HistoryPage.routeName),
            tooltip: '历史记录',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.restaurant_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('拍照识别热量', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '拍一张食物照片，AI 自动识别\n并计算每项食物的热量',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: '开始识别',
              icon: Icons.camera_alt_rounded,
              onPressed: _showPicker,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
