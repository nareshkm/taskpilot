import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_providers.dart';
import '../../models/meal_item.dart';
import 'water_tracker_provider.dart';
import 'meal_planner_provider.dart';
import 'todo_provider.dart';

/// Dashboard page displaying date picker and top priorities.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  static const List<String> _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    // Filter priorities for the selected date or include repetitive tasks
    final allPriorities = ref.watch(topPrioritiesProvider);
    final priorities = allPriorities
        .where((t) => t.isRepetitive || _isSameDate(t.date, selectedDate))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker(context, ref, selectedDate),
          const SizedBox(height: 24),
          Text('Top Priorities', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildPrioritiesList(context, ref, priorities),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              onPressed: () => _showAddPriorityDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Text('To-Do List', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // Build to-do list
          _buildTodoList(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              onPressed: () => _showAddTodoDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Text('Water Tracker', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildWaterTracker(context, ref),
          const SizedBox(height: 24),
          Text('Meal Planning', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildMealPlanner(context, ref),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(
        7, (i) => startOfWeek.add(Duration(days: i)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabels[(date.weekday - 1) % 7],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrioritiesList(
      BuildContext context, WidgetRef ref, List priorities) {
    return priorities.isEmpty
        ? Text('No priorities added.',
            style: Theme.of(context).textTheme.bodyMedium)
        : ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: priorities.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(topPrioritiesProvider.notifier)
                  .reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = priorities[index];
              return ListTile(
                key: ValueKey(task.id),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
                leading: IconButton(
                  icon: Icon(
                    task.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: () {
                    ref
                        .read(topPrioritiesProvider.notifier)
                        .toggleComplete(task.id);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref
                            .read(topPrioritiesProvider.notifier)
                            .remove(task.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }

  void _showAddPriorityDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Priority'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Priority title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // Schedule priority for the currently selected date
                final date = ref.read(selectedDateProvider);
                ref.read(topPrioritiesProvider.notifier)
                    .add(text, date: date, isRepetitive: false);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  /// Water intake tracker UI with tappable cup icons.
  Widget _buildWaterTracker(BuildContext context, WidgetRef ref) {
    final count = ref.watch(waterTrackerProvider);
    return Wrap(
      spacing: 8,
      children: List.generate(8, (i) {
        final filled = i < count;
        return GestureDetector(
          onTap: () => ref.read(waterTrackerProvider.notifier).setCount(i + 1),
          child: Icon(
            Icons.local_drink,
            size: 32,
            color: filled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }),
    );
  }

  /// Meal planner UI grouped by meal types.
  Widget _buildMealPlanner(BuildContext context, WidgetRef ref) {
    final items = ref.watch(mealPlannerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: MealType.values.map((type) {
        final typeItems = items.where((e) => e.type == type).toList();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mealTypeLabel(type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                ...typeItems.map(
                  (item) => ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ref
                          .read(mealPlannerProvider.notifier)
                          .remove(item.id),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    onPressed: () => _showAddMealDialog(context, ref, type),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _mealTypeLabel(MealType type) {
    switch (type) {
      case MealType.Breakfast:
        return 'Breakfast';
      case MealType.Lunch:
        return 'Lunch';
      case MealType.Dinner:
        return 'Dinner';
      case MealType.Snacks:
        return 'Snacks';
    }
  }

  /// Dialog to add a new meal entry for [type].
  void _showAddMealDialog(
      BuildContext context, WidgetRef ref, MealType type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${_mealTypeLabel(type)}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Meal description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(mealPlannerProvider.notifier).add(type, text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// To-Do List UI with reorderable tasks.
  Widget _buildTodoList(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    // Filter tasks for the selected date or include repetitive tasks
    final allTasks = ref.watch(todoListProvider);
    final tasks = allTasks
        .where((t) => t.isRepetitive || _isSameDate(t.date, selectedDate))
        .toList();
    return tasks.isEmpty
        ? Text('No tasks added.', style: Theme.of(context).textTheme.bodyMedium)
        : ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: tasks.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(todoListProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                key: ValueKey(task.id),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
                leading: IconButton(
                  icon: Icon(
                    task.completed ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
                  onPressed: () => ref.read(todoListProvider.notifier).toggleComplete(task.id),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ref.read(todoListProvider.notifier).remove(task.id),
                    ),
                  ],
                ),
              );
            },
          );
  }

  /// Dialog to add a new to-do task.
  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Task description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // Schedule task for the currently selected date
                final date = ref.read(selectedDateProvider);
                ref.read(todoListProvider.notifier)
                    .add(text, date: date, isRepetitive: false);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Compare two DateTimes ignoring time portion.
bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}