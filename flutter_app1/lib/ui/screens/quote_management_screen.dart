import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/local_db_service.dart';
import '../../data/models/quote.dart';
import '../../data/services/quote_service.dart'; // 引入 QuoteService

class QuoteManagementScreen extends ConsumerStatefulWidget {
  const QuoteManagementScreen({super.key});

  @override
  ConsumerState<QuoteManagementScreen> createState() => _QuoteManagementScreenState();
}

class _QuoteManagementScreenState extends ConsumerState<QuoteManagementScreen> {
  // 用於多選合併
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // 進入頁面時檢查是否需要匯入預設雞湯
    _initDefaults();
  }

  Future<void> _initDefaults() async {
    await ref.read(quoteServiceProvider).checkAndImportDefaults();
    if (mounted) setState(() {}); // 匯入完成後刷新列表
  }

  @override
  Widget build(BuildContext context) {
    final dbService = ref.watch(localDbServiceProvider);
    // 每次 build 都重新抓取資料 (簡單實作，若資料量大建議改用 Stream/Provider)
    final sources = dbService.getAllQuoteSources();

    return Scaffold(
      appBar: AppBar(
        title: const Text('雞湯集管理'),
        actions: [
          if (_selectedIds.length > 1)
            TextButton.icon(
              icon: const Icon(Icons.merge_type, color: Colors.white),
              label: const Text('合併', style: TextStyle(color: Colors.white)),
              onPressed: () => _showMergeDialog(sources),
            ),
        ],
      ),
      body: sources.isEmpty
          ? const Center(child: Text('目前沒有匯入任何雞湯集'))
          : ListView.builder(
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                final isSelected = _selectedIds.contains(source.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedIds.add(source.id);
                          } else {
                            _selectedIds.remove(source.id);
                          }
                        });
                      },
                    ),
                    title: Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${source.quotes.length} 句 • ${DateFormat('yyyy/MM/dd').format(source.importedAt)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: source.isEnabled,
                          onChanged: (val) {
                            dbService.toggleQuoteSource(source.id, val);
                            setState(() {}); // 刷新 UI
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'export') _exportSource(source);
                            if (value == 'delete') _deleteSource(source);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'export', child: Text('匯出 JSON')),
                            const PopupMenuItem(value: 'delete', child: Text('刪除', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showMergeDialog(List<QuoteSource> allSources) async {
    final controller = TextEditingController();
    final selectedNames = allSources
        .where((s) => _selectedIds.contains(s.id))
        .map((s) => s.name)
        .join(' + ');
    
    controller.text = "合併集";

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('合併雞湯集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('即將合併：\n$selectedNames', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: '新名稱', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(localDbServiceProvider).mergeQuoteSources(
                      _selectedIds.toList(),
                      controller.text,
                    );
                setState(() => _selectedIds.clear());
                Navigator.pop(context);
              }
            },
            child: const Text('確認合併'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSource(QuoteSource source) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除「${source.name}」嗎？\n裡面的 ${source.quotes.length} 句雞湯也會一併消失。'),
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
      ref.read(localDbServiceProvider).deleteQuoteSource(source.id);
      setState(() {
        _selectedIds.remove(source.id);
      });
    }
  }

  Future<void> _exportSource(QuoteSource source) async {
    try {
      // 1. 轉換為 JSON
      final jsonList = source.quotes.map((q) => q.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      // 2. 寫入暫存檔
      final tempDir = await getTemporaryDirectory();
      final fileName = '${source.name}_export.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 3. 分享
      await Share.shareXFiles([XFile(file.path)], text: '匯出雞湯集：${source.name}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('匯出失敗: $e')),
        );
      }
    }
  }
}