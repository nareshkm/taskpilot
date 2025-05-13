import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/meal_item.dart';

/// StateNotifier managing meal plan entries with Hive persistence.
class MealPlannerNotifier extends StateNotifier<List<MealItem>> {
  final Box<MealItem> _box;
  MealPlannerNotifier()
      : _box = Hive.box<MealItem>('meals'),
        super(Hive.box<MealItem>('meals').values.toList());

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
  return MealPlannerNotifier();
});