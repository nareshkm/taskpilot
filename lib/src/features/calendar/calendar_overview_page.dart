import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/shared_task.dart';
import '../../models/user.dart';
import '../../models/task.dart';
import '../../providers/shared_data_provider.dart';
import '../dashboard/todo_provider.dart';
import '../../providers/auth_provider.dart';

class CalendarOverviewPage extends ConsumerStatefulWidget {
  const CalendarOverviewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarOverviewPage> createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends ConsumerState<CalendarOverviewPage> {
  DateTime _selectedDay = DateTime.now();

  List<DateTime> _getCurrentWeekDays() {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: today.weekday % 7));
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final allTasks = ref.watch(todoListProvider);

    final tasks = allTasks.where((t) {
      final sameDay = t.date.year == _selectedDay.year &&
          t.date.month == _selectedDay.month &&
          t.date.day == _selectedDay.day;
      return t.ownerId == currentUser.id && (sameDay || t.isRepetitive);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Overview'),
      ),
      body: Column(
        children: [
          _buildHorizontalDaySelector(theme),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks for selected day.', style: theme.textTheme.bodyMedium))
                : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.12),
              ),
              itemBuilder: (context, index) {
                final t = tasks[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(todoListProvider.notifier).toggleComplete(t.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(todoListProvider.notifier).toggleComplete(t.id);
                          },
                          child: Icon(
                            t.completed ? Icons.check_box : Icons.check_box_outline_blank,
                            color: t.completed ? theme.colorScheme.primary : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: t.completed ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: t.completed ? Colors.grey : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.jm().format(t.date),
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildHorizontalDaySelector(ThemeData theme) {
    final weekDays = _getCurrentWeekDays();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isSelected = day.day == _selectedDay.day &&
              day.month == _selectedDay.month &&
              day.year == _selectedDay.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(day),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
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

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Time: ${selectedTime.format(ctx2)}', style: Theme.of(ctx2).textTheme.bodyMedium),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: ctx2,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState2(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: const Text('Select'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      final dateTime = DateTime(
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      final user = ref.read(currentUserProvider);
                      ref.read(todoListProvider.notifier).add(
                        title,
                        date: dateTime,
                        isRepetitive: false,
                        ownerId: user.id,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}