import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood.dart';
import '../models/quote.dart';
import 'local_db_service.dart';
import '../../objectbox.g.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return QuoteService(dbService);
});

class QuoteService {
  final LocalDbService _dbService;

  QuoteService(this._dbService);

  /// 檢查是否已匯入內建雞湯，若無則匯入 DB
  Future<void> checkAndImportDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyImported = prefs.getBool('has_imported_builtin_quotes') ?? false;

    if (alreadyImported) return;

    // 讀取 Assets
    final jsonString = await rootBundle.loadString('assets/data/quotes.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    final quotes = jsonList.map((q) => Quote(
      content: q['content'],
      category: q['category'],
      author: q['author'],
    )).toList();

    // 匯入到資料庫
    _dbService.importQuotes('預設雞湯', quotes);

    // 標記為已匯入
    await prefs.setBool('has_imported_builtin_quotes', true);
  }

  Future<String> getQuoteForMood(Mood mood) async {
    await checkAndImportDefaults(); // 確保資料庫有資料

    final moodKey = mood.name; // happy, sad...

    // 統一從 DB 撈取 (包含剛匯入的預設雞湯)
    final query = _dbService.quoteBox
        .query(Quote_.category.equals(moodKey))
        .build();
    
    // 過濾：只保留來源為 null (舊資料) 或 來源被啟用 的雞湯
    final customMatches = query.find().where((q) {
      final source = q.source.target;
      return source == null || source.isEnabled;
    }).toList();
    query.close();

    if (customMatches.isEmpty) {
      return "今天也要加油喔！"; // Fallback
    }

    // 4. 隨機抽選
    final random = Random();
    final selected = customMatches[random.nextInt(customMatches.length)];

    return selected.content;
  }
}