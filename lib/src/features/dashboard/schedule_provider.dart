import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/schedule_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier for managing daily schedules with Hive persistence.
class ScheduleListNotifier extends StateNotifier<List<ScheduleItem>> {
  final Box<ScheduleItem> _box;
  final String _ownerId;
  ScheduleListNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a schedule entry with [title], [start], and [end] datetimes.
  void add(String title, {required DateTime start, required DateTime end}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = ScheduleItem(id: id, start: start, end: end, title: title);
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove a schedule entry by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }

  /// Update an existing schedule entry by [id].
  void update(ScheduleItem updatedItem) {
    _box.put(updatedItem.id, updatedItem);
    state = state.map((s) => s.id == updatedItem.id ? updatedItem : s).toList();
  }
}

/// Provider exposing the list of schedule entries.
final scheduleListProvider =
    StateNotifierProvider<ScheduleListNotifier, List<ScheduleItem>>(
            (ref) {
          final box =   ref.watch(schedulesBoxProvider);
          final ownerId = ref.watch(currentUserProvider).id;
          return ScheduleListNotifier(box, ownerId);
        }
);