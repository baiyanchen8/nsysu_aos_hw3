import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/mood.dart';

class MoodPieChart extends StatelessWidget {
  final List<DiaryEntry> entries;

  const MoodPieChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text("這段時間沒有日記數據"));
    }

    // 1. 統計每個心情的數量
    final moodCounts = <Mood, int>{};
    for (var entry in entries) {
      moodCounts.update(entry.mood, (value) => value + 1, ifAbsent: () => 1);
    }

    // 2. 轉換為 Chart Data
    final total = entries.length;

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2, // 區塊間距
          centerSpaceRadius: 40, // 中空半徑
          sections: moodCounts.entries.map((entry) {
            final mood = entry.key;
            final count = entry.value;
            final percentage = (count / total * 100).toStringAsFixed(1);

            return PieChartSectionData(
              color: mood.color,
              value: count.toDouble(),
              title: '${mood.label}\n$percentage%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
              badgeWidget: Text(
                mood.representativeEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              badgePositionPercentageOffset: 1.3, // Emoji 顯示在圓餅外
            );
          }).toList(),
        ),
      ),
    );
  }
}
