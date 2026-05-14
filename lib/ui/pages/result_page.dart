import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/record_repository.dart';
import '../../services/api_client.dart';
import '../../services/app_config.dart';
import '../../services/nutrition_cache.dart';
import '../../services/record_service.dart';
import '../widgets/portion_selector.dart';
import 'history_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  static const routeName = '/result';

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final String _imagePath;
  final _apiClient = ApiClient(config: AppConfig.apiConfig);
  final _nutritionCache = NutritionCache();
  final _recordService = RecordService(RecordRepository());

  bool _isLoading = true;
  String? _error;
  List<_EditableItem> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imagePath = ModalRoute.of(context)!.settings.arguments as String;
    if (_items.isEmpty && _error == null) {
      _recognize();
    }
  }

  Future<void> _recognize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 模拟 1 秒加载
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _items = [
        _EditableItem(
          id: RecordRepository.generateId(),
          foodName: '米饭',
          confidence: 0.95,
          caloriePerGram: 1.16,
          weightGrams: 180,
        ),
        _EditableItem(
          id: RecordRepository.generateId(),
          foodName: '鸡胸肉',
          confidence: 0.88,
          caloriePerGram: 1.65,
          weightGrams: 120,
        ),
        _EditableItem(
          id: RecordRepository.generateId(),
          foodName: '西兰花',
          confidence: 0.92,
          caloriePerGram: 0.34,
          weightGrams: 90,
        ),
      ];
      _isLoading = false;
    });
  }

  double get _totalCalorie => _items.fold(
        0,
        (sum, item) => sum + item.weightGrams * item.caloriePerGram,
      );

  void _addItem() {
    setState(() {
      _items.add(_EditableItem(
        id: RecordRepository.generateId(),
        foodName: '手动添加',
        confidence: 1.0,
        caloriePerGram: 1.0,
        weightGrams: 100,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    final items = _items
        .map((e) => RecordItem(
              id: e.id,
              recordId: '',
              foodName: e.foodName,
              confidence: e.confidence,
              weightGrams: e.weightGrams,
              caloriePerGram: e.caloriePerGram,
              itemCalorie: e.weightGrams * e.caloriePerGram,
            ))
        .toList();

    await _recordService.createRecord(
      imageLocalUri: _imagePath,
      items: items,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }

  Future<void> _saveAndViewHistory() async {
    await _save();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HistoryPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _recognize,
            tooltip: '重新识别',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView(textTheme)
              : _buildResults(textTheme),
    );
  }

  Widget _buildErrorView(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _recognize,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(TextTheme textTheme) {
    final total = _totalCalorie;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length + 1,
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('添加食物'),
                );
              }
              return _buildItemCard(index, textTheme);
            },
          ),
        ),
        _buildBottomBar(total, textTheme),
      ],
    );
  }

  Widget _buildItemCard(int index, TextTheme textTheme) {
    final item = _items[index];
    final cal = (item.weightGrams * item.caloriePerGram).toStringAsFixed(1);

    return Card.filled(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.foodName, style: textTheme.titleMedium),
                ),
                Text('$cal kcal', style: textTheme.titleSmall),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () => _removeItem(index),
                  tooltip: '删除',
                ),
              ],
            ),
            const SizedBox(height: 8),
            PortionSelector(
              initialGrams: item.weightGrams,
              onChanged: (grams) {
                setState(() => item.weightGrams = grams);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(double total, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('总热量', style: textTheme.labelMedium),
                Text(
                  '${total.toStringAsFixed(1)} kcal',
                  style: textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _saveAndViewHistory,
            child: const Text('保存并查看历史'),
          ),
        ],
      ),
    );
  }
}

class _EditableItem {
  final String id;
  String foodName;
  final double confidence;
  double caloriePerGram;
  double weightGrams;

  _EditableItem({
    required this.id,
    required this.foodName,
    required this.confidence,
    required this.caloriePerGram,
    required this.weightGrams,
  });
}
