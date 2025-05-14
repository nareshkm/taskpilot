import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';

/// StateNotifier managing the to-do list tasks with Hive persistence.
class TodoListNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _box;
  TodoListNotifier()
      : _box = Hive.box<Task>('todos'),
        super(Hive.box<Task>('todos').values.toList());

  /// Add a new to-do task with [title], scheduled for [date], owned by [ownerId].
  /// If [isRepetitive] is true, the task appears on every date.
  void add(
    String title, {
    required DateTime date,
    bool isRepetitive = false,
    required String ownerId,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final task = Task(
      id: id,
      title: title,
      date: date,
      isRepetitive: isRepetitive,
      ownerId: ownerId,
    );
    _box.put(id, task);
    state = [...state, task];
    // Schedule reminder for this task
    NotificationService().scheduleTaskReminder(task);
  }

  /// Remove a task by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((t) => t.id != id).toList();
    // Cancel any scheduled reminder
    NotificationService().cancelTaskReminder(id);
  }

  /// Toggle completion of task by [id].
  void toggleComplete(String id) {
    final updated = state
        .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    state = updated;
    final task = updated.firstWhere((t) => t.id == id);
    _box.put(task.id, task);
  }

  /// Reorder tasks from [oldIndex] to [newIndex].
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    // Persist new order by rewriting box
    _box.clear();
    for (final t in list) {
      _box.put(t.id, t);
    }
  }
  /// Carry over unfinished, non-repetitive tasks from the previous day to [date].
  void carryOverUnfinished(DateTime date) {
    final prev = date.subtract(const Duration(days: 1));
    final unfinished = state.where((t) =>
        !t.completed &&
        !t.isRepetitive &&
        t.date.year == prev.year &&
        t.date.month == prev.month &&
        t.date.day == prev.day);
    for (final t in unfinished) {
      add(t.title, date: date, isRepetitive: false, ownerId: t.ownerId);
    }
  }
}

/// Provider exposing the to-do list tasks.
final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<Task>>(
  (ref) => TodoListNotifier(),
);