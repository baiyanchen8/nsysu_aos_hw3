import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/diary_entry.dart';
import '../data/services/local_db_service.dart';

// 時間範圍過濾器
enum TimeRange { week, month }

final timeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.week);

// 統計資料 Provider
final moodStatsProvider = FutureProvider.autoDispose<List<DiaryEntry>>((
  ref,
) async {
  final db = ref.watch(localDbServiceProvider);
  final range = ref.watch(timeRangeProvider);

  final now = DateTime.now();
  DateTime start;
  DateTime end = now;

  if (range == TimeRange.week) {
    // 過去 7 天
    start = now.subtract(const Duration(days: 7));
  } else {
    // 過去 30 天
    start = now.subtract(const Duration(days: 30));
  }

  // 確保包含整天
  start = DateTime(start.year, start.month, start.day);
  end = DateTime(end.year, end.month, end.day, 23, 59, 59);

  return db.getEntriesInRange(start, end);
});
