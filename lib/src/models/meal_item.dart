/// Represents a meal entry for a specific meal type.
enum MealType { Breakfast, Lunch, Dinner, Snacks }

/// A simple MealItem model for meal planning.
class MealItem {
  final String id;
  final MealType type;
  final String description;

  MealItem({
    required this.id,
    required this.type,
    required this.description,
  });

  MealItem copyWith({String? id, MealType? type, String? description}) {
    return MealItem(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }
}