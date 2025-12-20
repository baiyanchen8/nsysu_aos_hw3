import 'dart:async'; // 1. 引入 async 用來處理 TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood.dart';

class RemoteAiService {
  static Future<String?> getAiQuote(
    String serverUrl,
    String content,
    Mood mood,
  ) async {
    try {
      final uri = Uri.parse('$serverUrl/api/generate_quote');

      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "content": content,
              "mood": mood.name,
              "date": DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5)); // 2. 設定 5 秒超時

      if (response.statusCode == 200) {
        // ... 解析 JSON (保持不變)
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['quote'] as String;
      } else {
        return null;
      }
    } on TimeoutException catch (_) {
      // 3. 捕捉超時錯誤
      print("AI 連線逾時 (超過 5 秒)，切換回本地模式");
      return null; // 回傳 null，讓 EditorScreen 自動切回本地
    } catch (e) {
      print("連線失敗: $e");
      return null;
    }
  }
}
