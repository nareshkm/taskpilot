import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dashboard/todo_provider.dart';
import '../dashboard/dashboard_providers.dart';
import '../dashboard/expense_provider.dart';
import '../../services/report_export_service.dart';

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

    final expenseItems = ref.watch(expenseListProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Weekly Productivity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
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
                        meta: meta,
                        child: Text(labels[idx], style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Expense Trend (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: _buildExpenseGroups(context, ref),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      final labels = _buildExpenseLabels();
                      if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(labels[idx], style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Task Completion Rate (This Week)', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildCompletionSections(allTasks),
              sectionsSpace: 4,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Habit-formation insights
        Builder(builder: (context) {
          // Compute daily completed task counts
          final todayDate = DateTime.now();
          List<int> counts = List.generate(7, (i) {
            final day = DateTime(todayDate.year, todayDate.month, todayDate.day)
                .subtract(Duration(days: 6 - i));
            return allTasks.where((t) {
              if (!t.completed) return false;
              if (t.isRepetitive) return true;
              return t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day;
            }).length;
          });
          // Calculate streak of days >= 3 tasks
          int streak = 0;
          for (int offset = 0; offset < 7; offset++) {
            final count = counts[6 - offset];
            if (count >= 3) streak++; else break;
          }
          // Calculate 7-day average
          final average = counts.fold<int>(0, (sum, c) => sum + c) / 7.0;
          // Show badge if streak achieved
          return Row(
            children: [
              Text('Habit Streak: $streak day${streak == 1 ? '' : 's'}', style: Theme.of(context).textTheme.titleMedium),
              if (streak >= 3) ...[
                const SizedBox(width: 8),
                Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.secondary),
              ],
              const SizedBox(width: 16),
              Text('7-Day Avg: ${average.toStringAsFixed(1)} tasks/day', style: Theme.of(context).textTheme.titleMedium),
            ],
          );
        }),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Export Report'),
            onPressed: () => ReportExportService.exportReport(
              tasks: allTasks,
              expenses: expenseItems,
            ),
          ),
        ),
        ],
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return labels[(weekday - 1) % 7];
  }
  
  /// Build bar groups for expense trend over last 7 days.
  List<BarChartGroupData> _buildExpenseGroups(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);
    final today = DateTime.now();
    List<BarChartGroupData> groups = [];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final sum = expenses
          .where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
          .fold<double>(0, (prev, e) => prev + e.amount);
      groups.add(BarChartGroupData(
        x: 6 - i,
        barRods: [BarChartRodData(toY: sum, color: Theme.of(context).colorScheme.secondary, width: 12)],
      ));
    }
    return groups;
  }
  
  /// Get weekday labels for the last 7 days.
  List<String> _buildExpenseLabels() {
    final today = DateTime.now();
    final List<String> labels = [];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      labels.add(_weekdayLabel(day.weekday));
    }
    return labels;
  }
  
  /// Build pie sections for task completion rate.
  List<PieChartSectionData> _buildCompletionSections(List allTasks) {
    final total = allTasks.length.toDouble();
    final completed = allTasks.where((t) => t.completed).length.toDouble();
    final incomplete = total - completed;
    if (total == 0) {
      return [PieChartSectionData(value: 1, color: Colors.grey, title: 'No Data')];
    }
    return [
      PieChartSectionData(
        value: completed,
        color: Colors.greenAccent,
        title: '${(completed / total * 100).toStringAsFixed(0)}%',
      ),
      PieChartSectionData(
        value: incomplete,
        color: Colors.redAccent,
        title: '${(incomplete / total * 100).toStringAsFixed(0)}%',
      ),
    ];
  }
}