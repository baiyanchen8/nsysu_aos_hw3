import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // 使用 TextEditingController 來管理輸入框
    final urlController = TextEditingController(text: settings.serverUrl);

    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("啟用 AI 遠端生成模式"),
            subtitle: const Text("將日記傳送到伺服器進行深度分析"),
            value: settings.isRemoteMode,
            onChanged: (value) {
              notifier.setRemoteMode(value);
            },
            secondary: Icon(
              settings.isRemoteMode ? Icons.cloud_done : Icons.cloud_off,
              color: settings.isRemoteMode ? Colors.blue : Colors.grey,
            ),
          ),

          if (settings.isRemoteMode) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: "伺服器位址 (Server IP)",
                  hintText: "http://192.168.1.100:8000",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                onSubmitted: (value) {
                  notifier.setServerUrl(value); // 按 Enter 儲存
                },
                onEditingComplete: () {
                  notifier.setServerUrl(urlController.text); // 離開焦點儲存
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "請輸入完整網址，包含 http:// 與埠號。",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
