import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dashboard/todo_provider.dart';
import '../dashboard/dashboard_providers.dart';

/// Reports page showing a bar chart of completed tasks over the last 7 days.
class ReportsPage extends ConsumerWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoTasks = ref.watch(todoListProvider);
    final priorityTasks = ref.watch(topPrioritiesProvider);
    final allTasks = [...todoTasks, ...priorityTasks];
    
    // Generate counts per day for last 7 days
    final today = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];
    for (var i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      // Count tasks completed on this date, including repetitive tasks
      final count = allTasks.where((t) {
        if (!t.completed) return false;
        if (t.isRepetitive) return true;
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day;
      }).length;
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      labels.add(_weekdayLabel(date.weekday));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Productivity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(labels[idx], style: Theme.of(context).textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return labels[(weekday - 1) % 7];
  }
}