import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/mood.dart';

class QuoteService {
  // 隨機抽選一句雞湯
  static Future<String> getQuoteForMood(Mood mood) async {
    try {
      // 1. 讀取 JSON 檔案
      final String jsonString = await rootBundle.loadString(
        'assets/data/quotes.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 2. 篩選符合當下心情的語錄
      // Mood.name 會回傳 "happy", "sad" 等字串，這必須跟 JSON 的 category 一致
      final List<dynamic> matchingQuotes = jsonList.where((item) {
        return item['category'] == mood.name;
      }).toList();

      if (matchingQuotes.isEmpty) {
        return "今天也要加油喔！"; // 萬一沒對應到，給個預設值
      }

      // 3. 隨機選一個
      final random = Random();
      final index = random.nextInt(matchingQuotes.length);
      return matchingQuotes[index]['content'] as String;
    } catch (e) {
      print("讀取語錄失敗: $e");
      return "心靜自然涼。"; // 發生錯誤時的備案
    }
  }
}
