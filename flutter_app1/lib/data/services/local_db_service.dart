import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/objectbox.dart';
import '../models/diary_entry.dart';
import '../models/quote.dart';
import '../../objectbox.g.dart'; // 這是自動生成的，等下會有

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  throw UnimplementedError();
});

class LocalDbService {
  late final Store store;
  late final Box<DiaryEntry> box;
  late final Box<Quote> quoteBox;
  late final Box<QuoteSource> quoteSourceBox;

  LocalDbService._create(this.store) {
    box = store.box<DiaryEntry>();
    quoteBox = store.box<Quote>();
    quoteSourceBox = store.box<QuoteSource>();
  }

  static Future<LocalDbService> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // ObjectBox 資料庫存放在 documents/objectbox 資料夾中
    final store = await openStore(directory: p.join(docsDir.path, "objectbox"));
    return LocalDbService._create(store);
  }

  // --- CRUD ---

  Future<void> saveEntry(DiaryEntry entry) async {
    entry.date = cleanDate(entry.date);
    // put: id 為 0 時新增，非 0 時更新
    box.put(entry);
  }

  DiaryEntry? getEntryByDate(DateTime date) {
    final targetDate = cleanDate(date);

    // ObjectBox 查詢語法
    // 使用 query builder
    final query = box
        .query(DiaryEntry_.date.equals(targetDate.millisecondsSinceEpoch))
        .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  // 取得特定時間範圍內的日記
  List<DiaryEntry> getEntriesInRange(DateTime start, DateTime end) {
    // ObjectBox 查詢
    final query = box
        .query(
          DiaryEntry_.date.between(
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ),
        )
        .build();

    final results = query.find();
    query.close();
    return results;
  }

  List<DiaryEntry> getEntriesForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final query = box
        .query(
          DiaryEntry_.date.between(
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ),
        )
        .build();

    final results = query.find();
    query.close();
    return results;
  }

  // ObjectBox 的 Watch 功能 (Stream)
  Stream<List<DiaryEntry>> watchEntriesForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final qBuilder = box.query(
      DiaryEntry_.date.between(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ),
    );

    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  void deleteEntry(int id) {
    box.remove(id);
  }

  DateTime cleanDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // --- Backup & Restore ---
  List<DiaryEntry> getAllEntries() {
    return box.getAll();
  }

  void restoreEntries(List<DiaryEntry> entries) {
    box.putMany(entries);
  }

  // --- Quotes ---
  // 匯入雞湯集
  void importQuotes(String sourceName, List<Quote> quotes) {
    final source = QuoteSource(
      name: sourceName,
      importedAt: DateTime.now(),
      isEnabled: true,
    );
    // 將雞湯關聯到這個來源
    source.quotes.addAll(quotes);
    quoteSourceBox.put(source);
  }

  List<QuoteSource> getAllQuoteSources() {
    return quoteSourceBox.getAll();
  }

  // 切換啟用狀態
  void toggleQuoteSource(int id, bool isEnabled) {
    final source = quoteSourceBox.get(id);
    if (source != null) {
      source.isEnabled = isEnabled;
      quoteSourceBox.put(source);
    }
  }

  // 刪除雞湯集 (連同裡面的雞湯一起刪除)
  void deleteQuoteSource(int id) {
    final source = quoteSourceBox.get(id);
    if (source != null) {
      // 先刪除關聯的雞湯
      // 注意：ObjectBox 預設不會 Cascade Delete，需手動處理
      final quoteIds = source.quotes.map((q) => q.id).toList();
      quoteBox.removeMany(quoteIds);
      // 再刪除來源
      quoteSourceBox.remove(id);
    }
  }

  // 合併雞湯集
  void mergeQuoteSources(List<int> sourceIds, String newName) {
    final sources = quoteSourceBox.getMany(sourceIds).whereType<QuoteSource>().toList();
    if (sources.isEmpty) return;

    final newSource = QuoteSource(
      name: newName,
      importedAt: DateTime.now(),
      isEnabled: true,
    );

    // 收集所有舊來源的雞湯
    final allQuotes = <Quote>[];
    for (final s in sources) {
      allQuotes.addAll(s.quotes);
    }

    // 將雞湯移動到新來源 (ObjectBox 會自動更新關聯)
    newSource.quotes.addAll(allQuotes);
    quoteSourceBox.put(newSource);

    // 刪除舊來源 (雞湯已經移走了，所以這裡只刪除 Source 本體)
    quoteSourceBox.removeMany(sourceIds);
  }
}
