import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../widgets/mood_pie_chart.dart';
import '../widgets/mood_jar_game.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(moodStatsProvider);
    final timeRange = ref.watch(timeRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('心情統計'),
        actions: [
          // 切換 一週 / 一個月
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<TimeRange>(
              value: timeRange,
              underline: const SizedBox(),
              icon: const Icon(Icons.calendar_today),
              items: const [
                DropdownMenuItem(value: TimeRange.week, child: Text("最近 7 天")),
                DropdownMenuItem(
                  value: TimeRange.month,
                  child: Text("最近 30 天"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(timeRangeProvider.notifier).state = value;
                }
              },
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("還沒有足夠的資料來統計喔！", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.pie_chart), text: "情緒佔比"),
                    Tab(icon: Icon(Icons.local_drink), text: "情緒罐"),
                  ],
                  labelColor: Colors.orange,
                  indicatorColor: Colors.orange,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: 圓餅圖
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(child: MoodPieChart(entries: entries)),
                      ),

                      // Tab 2: 物理罐
                      // 這裡我們用 Container 裝飾一下，讓它看起來像個罐子
                      Center(
                        child: Container(
                          width: 300,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 4,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(32),
                            ),
                            color: Colors.white.withValues(
                              alpha: 0.1,
                            ), // 微透明玻璃感
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          // 裁切掉超出罐子的部分
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(28),
                            ),
                            child: MoodJarWidget(entries: entries),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
