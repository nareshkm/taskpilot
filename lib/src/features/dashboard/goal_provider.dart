import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/goal_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier for managing goals with Hive persistence.
class GoalListNotifier extends StateNotifier<List<GoalItem>> {
  final Box<GoalItem> _box;
  final String _ownerId;
  GoalListNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a new goal with [title] and [target].
  void add(String title, int target) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = GoalItem(id: id, title: title, target: target);
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove a goal by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((g) => g.id != id).toList();
  }

  /// Increment progress for a goal by [id].
  void incrementProgress(String id) {
    final updated = state.map((g) {
      if (g.id == id) {
        final newProgress = (g.progress + 1).clamp(0, g.target);
        final updatedGoal = g.copyWith(progress: newProgress);
        _box.put(id, updatedGoal);
        return updatedGoal;
      }
      return g;
    }).toList();
    state = updated;
  }
}

/// Provider exposing the list of goals.
final goalListProvider =
    StateNotifierProvider<GoalListNotifier, List<GoalItem>>(

     (ref) {
          final box =   ref.watch(goalsBoxProvider);
          final ownerId = ref.watch(currentUserProvider).id;
          return GoalListNotifier(box, ownerId);
        }
);