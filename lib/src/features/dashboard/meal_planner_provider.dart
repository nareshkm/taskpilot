import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/meal_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier managing meal plan entries with Hive persistence.
class MealPlannerNotifier extends StateNotifier<List<MealItem>> {
  final Box<MealItem> _box;
  final String _ownerId;
  MealPlannerNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a new meal entry of [type] with [description].
  void add(MealType type, String description) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = MealItem(id: id, type: type, description: description);
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove a meal entry by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((item) => item.id != id).toList();
  }
}

/// Provider exposing the list of meal entries.
final mealPlannerProvider =
    StateNotifierProvider<MealPlannerNotifier, List<MealItem>>((ref) {
      final box =  ref.watch(mealsBoxProvider);
      final ownerId = ref.watch(currentUserProvider).id;
      return MealPlannerNotifier(box, ownerId);
});