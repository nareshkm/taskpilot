import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../services/notification_service.dart';
import '../../models/task.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// Provider for the currently selected date on the dashboard.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// StateNotifier managing the top priorities list with Hive persistence.
class TopPrioritiesNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _box;
  final String _ownerId;
  TopPrioritiesNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a new priority task with [title], scheduled for [date], owned by [ownerId].
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
      ownerId: _ownerId,
    );
    _box.put(id, task);
    state = [...state, task];
    // Schedule reminder for priority task
    NotificationService().scheduleTaskReminder(task);
  }

  void remove(String id) {
    _box.delete(id);
    state = state.where((t) => t.id != id).toList();
    // Cancel scheduled reminder
    NotificationService().cancelTaskReminder(id);
  }

  void toggleComplete(String id) {
    final updated = state
        .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    state = updated;
    final task = updated.firstWhere((t) => t.id == id);
    _box.put(task.id, task);
  }

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
}

/// Provider exposing the list of top priorities.
final topPrioritiesProvider =
    StateNotifierProvider<TopPrioritiesNotifier, List<Task>>(
  (ref) {
    final box =  ref.watch(prioritiesBoxProvider);
    final ownerId = ref.watch(currentUserProvider).id;
    return TopPrioritiesNotifier(box, ownerId);
  }
);