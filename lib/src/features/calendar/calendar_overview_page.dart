import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../models/shared_task.dart';
import '../../models/user.dart';
import '../../models/task.dart';
import '../../providers/shared_data_provider.dart';
import '../dashboard/todo_provider.dart';

/// Page showing a calendar overview where users can pick dates and view tasks.
class CalendarOverviewPage extends ConsumerStatefulWidget {
  const CalendarOverviewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarOverviewPage> createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends ConsumerState<CalendarOverviewPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final allTasks = ref.watch(todoListProvider);
    // Tasks for selected day or repetitive
    final tasks = allTasks.where((t) {
      final sameDay = t.date.year == _selectedDay!.year &&
          t.date.month == _selectedDay!.month &&
          t.date.day == _selectedDay!.day;
      return t.ownerId == currentUser.id && (sameDay || t.isRepetitive);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Overview'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleLarge!,
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary, shape: BoxShape.circle),
              defaultTextStyle: theme.textTheme.bodyMedium!,
              weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.error),
              outsideDaysVisible: false,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.bodySmall!,
              weekendStyle: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final t = tasks[i];
                return Container(
                  color: i.isEven
                      ? theme.colorScheme.surfaceVariant
                      : theme.colorScheme.surface,
                  child: ListTile(
                    leading: Icon(
                      t.completed ? Icons.check_circle : Icons.circle_outlined,
                      color: t.completed
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.secondary,
                    ),
                    title: Text(
                      t.title,
                      style: t.completed
                          ? theme.textTheme.bodyLarge!
                              .copyWith(decoration: TextDecoration.lineThrough)
                          : theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                        DateFormat.jm().format(t.date) +
                            (t.isRepetitive ? ' • Daily' : ''),
                        style: theme.textTheme.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () => _showCommentsDialog(ctx: context, task: t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {},
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
    );
  }

  void _showCommentsDialog({
    required BuildContext ctx,
    required Task task,
  }) {
    final st = ref
        .read(sharedDataProvider)
        .sharedTasks
        .where((s) => s.taskId == task.id)
        .firstWhere(
            (s) => true, orElse: () =>
            SharedTask(
              id: '',
              taskId: task.id,
              fromUserId: '',
              toUserId: '',
              timestamp: DateTime.now(),
            ));
    final comments = (st.metadata['comments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text('Comments for "${task.title}"'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    final author = dummyUsers.firstWhere(
                        (u) => u.id == c['authorId'] as String,
                        orElse: () => dummyUsers.first);
                    return ListTile(
                      title: Text(author.name),
                      subtitle: Text(c['text'] as String),
                      trailing: Text(DateFormat.jm().format(
                          DateTime.parse(c['timestamp'] as String))),
                    );
                  },
                ),
              ),
              TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Add a comment'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final user = ref.read(currentUserProvider);
                  ref.read(sharedDataProvider.notifier).addComment(
                        sharedTaskId: st.id,
                        authorId: user.id,
                        text: text,
                      );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Submit')),
        ],
      ),
    );
  }
}