import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../../providers/shared_data_provider.dart';
import '../dashboard/dashboard_providers.dart';
import '../../models/meal_item.dart';
import 'water_tracker_provider.dart';
import 'meal_planner_provider.dart';
import 'todo_provider.dart';
import 'personal_todo_provider.dart';
import 'communication_provider.dart';
import '../../models/communication_item.dart';
import 'schedule_provider.dart';
import 'appointment_provider.dart';
import '../../models/appointment_item.dart';
import 'expense_provider.dart';
import '../../models/expense_item.dart';
import 'note_provider.dart';
import '../../models/note_item.dart';
import 'wellness_provider.dart';
import '../../models/wellness_item.dart';
import '../../services/notification_service.dart';
import 'package:hive/hive.dart';
import '../../models/user.dart';

/// Dashboard page displaying date picker and top priorities.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();

  static const List<String> _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Auto rollover unfinished tasks once per day, scheduled after first frame
    final box = Hive.box('settings');
    final lastDateStr = box.get('lastRolloverDate') as String?;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastDateStr != todayStr) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Carry over unfinished tasks from yesterday
        ref.read(todoListProvider.notifier).carryOverUnfinished(today);
        // Update rollover date
        box.put('lastRolloverDate', todayStr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
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
          // Personal To-Do List Section
          Text('Personal To-Do List', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildPersonalTodoList(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Personal Task'),
              onPressed: () => _showAddPersonalTodoDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Calls/Emails/Texts Section
          Text('Calls/Emails/Texts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildCommunicationList(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Communication'),
              onPressed: () => _showAddCommunicationDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Water Tracker Section
          Text('Water Tracker', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildWaterTracker(context, ref),
          const SizedBox(height: 24),
          Text('Meal Planning', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildMealPlanner(context, ref),
          const SizedBox(height: 24),
          // Daily Schedules Section
          Text('Daily Schedules', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildScheduleTimeline(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Add Schedule'),
              onPressed: () => _showAddScheduleDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Appointments Section
          Text('Appointments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildAppointmentList(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.event),
              label: const Text('Add Appointment'),
              onPressed: () => _showAddAppointmentDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Expense Tracker Section
          Text('Expense Tracker', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildExpenseTracker(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.attach_money),
              label: const Text('Add Expense'),
              onPressed: () => _showAddExpenseDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Notes & Staff Comments Section
          Text('Notes & Staff Comments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildNoteList(context, ref),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.note_add),
              label: const Text('Add Note'),
              onPressed: () => _showAddNoteDialog(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          // Wellness Section
          Text('Wellness', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildWellnessSection(context, ref),
          const SizedBox(height: 24),
          // Carry Over Unfinished Tasks
          Text('Carry Over Unfinished Tasks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => ref.read(todoListProvider.notifier).carryOverUnfinished(ref.read(selectedDateProvider)),
              child: const Text('Carry Over'),
            ),
          ),
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
                    DashboardPage._weekdayLabels[(date.weekday - 1) % 7],
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
              final baseColor = Theme.of(context).colorScheme.surfaceVariant;
              final tileColor = task.completed
                  ? baseColor.withOpacity(0.5)
                  : baseColor;
              return AnimatedContainer(
                key: ValueKey(task.id),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  tileColor: Colors.transparent,
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
              ));
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
              final priorities = ref.read(topPrioritiesProvider);
              if (priorities.length >= 3) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maximum of 3 priorities allowed.')),
                );
                return;
              }
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final date = ref.read(selectedDateProvider);
                final currentUser = ref.read(currentUserProvider);
                ref.read(topPrioritiesProvider.notifier).add(
                      text,
                      date: date,
                      isRepetitive: false,
                      ownerId: currentUser.id,
                    );
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
    final currentUser = ref.watch(currentUserProvider);
    final sharedState = ref.watch(sharedDataProvider);
    // Determine task IDs shared with this user
    final sharedToUser = sharedState.sharedTasks
        .where((st) => st.toUserId == currentUser.id)
        .map((st) => st.taskId)
        .toSet();
    // All tasks from Hive
    final allTasks = ref.watch(todoListProvider);
    // Filter by ownership or sharing
    final userTasks = allTasks.where((t) =>
        t.ownerId == currentUser.id || sharedToUser.contains(t.id));
    // Further filter tasks for the selected date or include repetitive tasks
    final tasks = userTasks
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
                      icon: const Icon(Icons.share),
                      tooltip: 'Share Task',
                      onPressed: () {
                        final currentUser = ref.read(currentUserProvider);
                        final collabs = ref
                            .read(sharedDataProvider)
                            .collaborations
                            .where((c) =>
                                c.user1 == currentUser.id ||
                                c.user2 == currentUser.id)
                            .toList();
                        String? selected;
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Share Task'),
                            content: DropdownButtonFormField<String>(
                              items: collabs.map((c) {
                                final otherId =
                                    c.user1 == currentUser.id
                                        ? c.user2
                                        : c.user1;
                                final other = dummyUsers
                                    .firstWhere((u) => u.id == otherId);
                                return DropdownMenuItem(
                                  value: other.id,
                                  child: Text(other.name),
                                );
                              }).toList(),
                              onChanged: (v) => selected = v,
                              decoration: const InputDecoration(
                                  labelText: 'Select collaborator'),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () {
                                    if (selected != null) {
                                      ref
                                          .read(
                                              sharedDataProvider.notifier)
                                          .shareTask(
                                            taskId: task.id,
                                            fromUserId: currentUser.id,
                                            toUserId: selected!,
                                          )
                                          .then((_) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Task shared')));
                                      });
                                    }
                                  },
                                  child: const Text('Share')),
                            ],
                          ),
                        );
                      },
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
                final date = ref.read(selectedDateProvider);
                // Impersonated user
                final currentUser = ref.read(currentUserProvider);
                ref.read(todoListProvider.notifier).add(
                      text,
                      date: date,
                      isRepetitive: false,
                      ownerId: currentUser.id,
                    );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Personal To-Do List UI with reorderable tasks.
  Widget _buildPersonalTodoList(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allTasks = ref.watch(personalTodoListProvider);
    final tasks = allTasks
        .where((t) => t.isRepetitive || _isSameDate(t.date, selectedDate))
        .toList();
    return tasks.isEmpty
        ? Text('No personal tasks added.', style: Theme.of(context).textTheme.bodyMedium)
        : ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: tasks.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(personalTodoListProvider.notifier).reorder(oldIndex, newIndex);
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
                  onPressed: () => ref.read(personalTodoListProvider.notifier).toggleComplete(task.id),
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
                      onPressed: () => ref.read(personalTodoListProvider.notifier).remove(task.id),
                    ),
                  ],
                ),
              );
            },
          );
  }

  /// Dialog to add a new personal to-do task.
  void _showAddPersonalTodoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Personal Task'),
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
                final date = ref.read(selectedDateProvider);
                final currentUser = ref.read(currentUserProvider);
                ref.read(personalTodoListProvider.notifier).add(
                      text,
                      date: date,
                      isRepetitive: false,
                      ownerId: currentUser.id,
                    );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  /// Calls/Emails/Texts UI with reorderable list.
  Widget _buildCommunicationList(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allItems = ref.watch(communicationListProvider);
    final items = allItems
        .where((i) => _isSameDate(i.date, selectedDate))
        .toList();
    return items.isEmpty
        ? Text('No communications added.', style: Theme.of(context).textTheme.bodyMedium)
        : ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(communicationListProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                key: ValueKey(item.id),
                tileColor: Theme.of(context).colorScheme.surfaceVariant,
                leading: IconButton(
                  icon: Icon(
                    item.completed ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
                  onPressed: () => ref
                      .read(communicationListProvider.notifier)
                      .toggleComplete(item.id),
                ),
                title: Row(
                  children: [
                    Icon(
                      _iconForCommunicationType(item.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.description)),
                  ],
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
                      onPressed: () => ref
                          .read(communicationListProvider.notifier)
                          .remove(item.id),
                    ),
                  ],
                ),
              );
            },
          );
  }

  /// Dialog to add a new communication item.
  void _showAddCommunicationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        CommunicationType selectedType = CommunicationType.Call;
        final controller = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Communication'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CommunicationType>(
                  value: selectedType,
                  items: CommunicationType.values.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toString().split('.').last),
                      )).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final desc = controller.text.trim();
                  if (desc.isNotEmpty) {
                    final date = ref.read(selectedDateProvider);
                    ref
                        .read(communicationListProvider.notifier)
                        .add(desc, type: selectedType, date: date);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Map a [CommunicationType] to its corresponding icon.
  IconData _iconForCommunicationType(CommunicationType type) {
    switch (type) {
      case CommunicationType.Call:
        return Icons.call;
      case CommunicationType.Email:
        return Icons.email;
      case CommunicationType.Text:
        return Icons.message;
    }
  }

  /// Timeline UI for the selected date's schedules.
  Widget _buildScheduleTimeline(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allSchedules = ref.watch(scheduleListProvider);
    final schedules = allSchedules
        .where((s) => _isSameDate(s.start, selectedDate))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    const int startHour = 6;
    const int endHour = 22;
    const double hourHeight = 60.0;
    final totalHeight = (endHour - startHour) * hourHeight;
    return SizedBox(
      height: 300, // fixed viewport height
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              // Hour lines and labels
              for (int h = startHour; h <= endHour; h++) ...[
                // Hour marker line
                Positioned(
                  top: (h - startHour) * hourHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                // Hour label, positioned slightly below the line to avoid overlap
                Positioned(
                  top: (h - startHour) * hourHeight + 4,
                  left: 4,
                  child: Text(
                    '${h.toString().padLeft(2, '0')}:00',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              // Schedule events
              for (var s in schedules) ...[
                Positioned(
                  top: ((s.start.hour + s.start.minute / 60) - startHour) * hourHeight,
                  left: 60,
                  right: 16,
                  height: ((s.end.difference(s.start).inMinutes) / 60) * hourHeight,
                  child: GestureDetector(
                    onLongPress: () => ref.read(scheduleListProvider.notifier).remove(s.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        s.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog to add a new schedule entry.
  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    final controller = TextEditingController();
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Event title'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (picked != null) {
                        setState(() => startTime = picked);
                      }
                    },
                    child: Text('Start: ${startTime.format(context)}'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (picked != null) {
                        setState(() => endTime = picked);
                      }
                    },
                    child: Text('End: ${endTime.format(context)}'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  final start = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      startTime.hour,
                      startTime.minute);
                  final end = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      endTime.hour,
                      endTime.minute);
                  ref
                      .read(scheduleListProvider.notifier)
                      .add(title, start: start, end: end);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Appointment list UI.
  Widget _buildAppointmentList(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final all = ref.watch(appointmentListProvider);
    final items = all
        .where((a) => a.start.year == selectedDate.year && a.start.month == selectedDate.month && a.start.day == selectedDate.day)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return items.isEmpty
        ? Text('No appointments added.', style: Theme.of(context).textTheme.bodyMedium)
        : Column(
            children: items.map((a) {
              final start = TimeOfDay.fromDateTime(a.start).format(context);
              final end = TimeOfDay.fromDateTime(a.end).format(context);
              return ListTile(
                key: ValueKey(a.id),
                leading: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                title: Text(a.title),
                subtitle: Text('$start – $end'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => ref.read(appointmentListProvider.notifier).remove(a.id),
                ),
              );
            }).toList(),
          );
  }

  /// Dialog to add new appointment.
  void _showAddAppointmentDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    final controller = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: startTime);
                      if (picked != null) setState(() => startTime = picked);
                    },
                    child: Text('Start: ${startTime.format(context)}'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: endTime);
                      if (picked != null) setState(() => endTime = picked);
                    },
                    child: Text('End: ${endTime.format(context)}'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
                  final end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);
                  ref.read(appointmentListProvider.notifier).add(title, start: start, end: end);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Expense tracker UI.
  Widget _buildExpenseTracker(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final all = ref.watch(expenseListProvider);
    final items = all.where((e) => e.date.year == selectedDate.year && e.date.month == selectedDate.month && e.date.day == selectedDate.day).toList();
    // Placeholder chart
    final total = items.fold<double>(0, (sum, e) => sum + e.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: Center(child: Text('Total: \$${total.toStringAsFixed(2)}')),
        ),
        ...items.map((e) => ListTile(
              title: Text(e.category),
              trailing: Text('\$${e.amount.toStringAsFixed(2)}'),
              onLongPress: () => ref.read(expenseListProvider.notifier).remove(e.id),
            )),
      ],
    );
  }

  /// Dialog to add a new expense.
  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    final controller = TextEditingController();
    String category = 'General';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (v) => category = v,
                decoration: const InputDecoration(hintText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(controller.text) ?? 0;
                if (amt > 0) {
                  ref.read(expenseListProvider.notifier).add(amt, category, date: selectedDate);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Note list UI.
  Widget _buildNoteList(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final all = ref.watch(noteListProvider);
    final items = all.where((n) => n.date.year == selectedDate.year && n.date.month == selectedDate.month && n.date.day == selectedDate.day).toList();
    return items.isEmpty
        ? Text('No notes added.', style: Theme.of(context).textTheme.bodyMedium)
        : Column(
            children: items.map((n) => ListTile(
                  key: ValueKey(n.id),
                  title: Text(n.content),
                  subtitle: n.staffComment != null ? Text('Staff: ${n.staffComment}') : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref.read(noteListProvider.notifier).remove(n.id),
                  ),
                )).toList(),
          );
  }

  /// Dialog to add a new note.
  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    final controller = TextEditingController();
    final staffController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Note content'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: staffController,
              decoration: const InputDecoration(hintText: 'Staff comment (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final content = controller.text.trim();
              final staff = staffController.text.trim();
              if (content.isNotEmpty) {
                ref.read(noteListProvider.notifier).add(content, date: selectedDate, staffComment: staff.isNotEmpty ? staff : null);
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
  /// UI for daily wellness: ratings and life balance.
  Widget _buildWellnessSection(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final all = ref.watch(wellnessListProvider);
    final item = all.firstWhere(
      (w) => _isSameDate(w.date, selectedDate),
      orElse: () => WellnessItem(
        id: selectedDate.millisecondsSinceEpoch.toString(),
        date: selectedDate,
        productivity: 3,
        mood: 3,
        health: 3,
        fitness: 3,
        family: 3,
        fun: 3,
        spiritual: 3,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rate Your Day', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildRatingRow(context, ref, 'Productivity', item.productivity, (v) {
          final updated = item.copyWith(productivity: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        _buildRatingRow(context, ref, 'Mood', item.mood, (v) {
          final updated = item.copyWith(mood: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        _buildRatingRow(context, ref, 'Health', item.health, (v) {
          final updated = item.copyWith(health: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        const SizedBox(height: 16),
        Text('Life Balance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildRatingRow(context, ref, 'Fitness', item.fitness, (v) {
          final updated = item.copyWith(fitness: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        _buildRatingRow(context, ref, 'Family & Friends', item.family, (v) {
          final updated = item.copyWith(family: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        _buildRatingRow(context, ref, 'Fun & Creation', item.fun, (v) {
          final updated = item.copyWith(fun: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
        _buildRatingRow(context, ref, 'Spiritual', item.spiritual, (v) {
          final updated = item.copyWith(spiritual: v);
          ref.read(wellnessListProvider.notifier).upsert(updated);
        }),
      ],
    );
  }

  Widget _buildRatingRow(BuildContext context, WidgetRef ref, String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Wrap(
            spacing: 4,
            children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                icon: Icon(
                  idx <= value ? Icons.star : Icons.star_border,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => onChanged(idx),
                iconSize: 24,
              );
            }),
          ),
        ),
      ],
    );
  }