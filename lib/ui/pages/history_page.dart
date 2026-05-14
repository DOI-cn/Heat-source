import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/record_repository.dart';
import '../../services/record_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _recordService = RecordService(RecordRepository());
  List<Record> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final records = await _recordService.getRecordsByDate(today);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _delete(String id) async {
    await _recordService.deleteRecord(id);
    _load();
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    final time = DateFormat('HH:mm').format(dt);

    if (date == today) return '今天 $time';
    if (date == today.subtract(const Duration(days: 1))) return '昨天 $time';
    return DateFormat('M月d日 HH:mm').format(dt);
  }

  double get _todayTotal => _records.fold(0, (sum, r) => sum + r.totalCalorie);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? _emptyView(textTheme)
                : _listView(textTheme),
      ),
    );
  }

  Widget _emptyView(TextTheme textTheme) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.restaurant_menu_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          '暂无记录',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '拍一张食物照片，开始记录你的饮食',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('去识别'),
          ),
        ),
      ],
    );
  }

  Widget _listView(TextTheme textTheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCard(textTheme),
        const SizedBox(height: 12),
        ..._records.map((record) => _recordCard(context, record, textTheme)),
      ],
    );
  }

  Widget _summaryCard(TextTheme textTheme) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日摄入', style: textTheme.labelLarge),
                Text(
                  '${_todayTotal.toStringAsFixed(0)} kcal',
                  style: textTheme.headlineMedium,
                ),
              ],
            ),
            const Spacer(),
            Text('${_records.length} 条记录',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }

  Widget _recordCard(BuildContext context, Record record, TextTheme textTheme) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除记录'),
            content: const Text('确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _delete(record.id),
      child: Card.outlined(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.restaurant_menu_rounded),
          title: Text(record.items.map((i) => i.foodName).join('、'),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(_formatTime(record.createdAt)),
          trailing: Text(
            '${record.totalCalorie.toStringAsFixed(0)} kcal',
            style: textTheme.titleSmall,
          ),
          onTap: () => _showDetail(context, record, textTheme),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Record record, TextTheme textTheme) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('记录详情', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(_formatTime(record.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            ...record.items.map((item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.foodName),
                  trailing: Text(
                    '${item.weightGrams.toStringAsFixed(0)}g · ${item.itemCalorie.toStringAsFixed(1)} kcal',
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('总热量', style: textTheme.labelLarge),
                Text('${record.totalCalorie.toStringAsFixed(1)} kcal',
                    style: textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
