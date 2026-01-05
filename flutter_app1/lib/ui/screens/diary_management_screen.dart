import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/local_db_service.dart';
import '../../data/models/diary_entry.dart';

class DiaryManagementScreen extends ConsumerStatefulWidget {
  const DiaryManagementScreen({super.key});

  @override
  ConsumerState<DiaryManagementScreen> createState() => _DiaryManagementScreenState();
}

class _DiaryManagementScreenState extends ConsumerState<DiaryManagementScreen> {
  final Set<int> _selectedIds = {};
  bool _isAllSelected = false;

  @override
  Widget build(BuildContext context) {
    final dbService = ref.watch(localDbServiceProvider);
    // 取得所有日記並按日期降序排列 (最新的在上面)
    final entries = dbService.getAllEntries()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('日記管理'),
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: '刪除選取項目',
              onPressed: () => _deleteSelected(entries),
            ),
        ],
      ),
      body: Column(
        children: [
          // 工具列：全選與統計
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isAllSelected,
                    onChanged: (value) {
                      setState(() {
                        _isAllSelected = value ?? false;
                        if (_isAllSelected) {
                          _selectedIds.addAll(entries.map((e) => e.id));
                        } else {
                          _selectedIds.clear();
                        }
                      });
                    },
                  ),
                  const Text('全選'),
                  const Spacer(),
                  Text(
                    '已選擇 ${_selectedIds.length} / ${entries.length} 筆',
                    style: TextStyle(
                      color: _selectedIds.isNotEmpty ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('目前沒有任何日記'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isSelected = _selectedIds.contains(entry.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: isSelected ? 4 : 1,
                        color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (val) => _toggleSelection(entry.id, entries.length),
                          ),
                          title: Text(
                            DateFormat('yyyy/MM/dd (E)', 'zh_TW').format(entry.date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            entry.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            entry.specificEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          onTap: () => _toggleSelection(entry.id, entries.length),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(int id, int totalCount) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _isAllSelected = _selectedIds.length == totalCount;
    });
  }

  Future<void> _deleteSelected(List<DiaryEntry> allEntries) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除選取的 ${_selectedIds.length} 篇日記嗎？\n此動作無法復原。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(localDbServiceProvider).deleteEntries(_selectedIds.toList());
      setState(() {
        _selectedIds.clear();
        _isAllSelected = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刪除成功')),
        );
      }
    }
  }
}