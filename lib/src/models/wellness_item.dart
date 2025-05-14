/// Represents a daily wellness entry including ratings for productivity, mood, health,
/// and life balance categories.
class WellnessItem {
  final String id;
  final DateTime date;
  final int productivity; // 1-5
  final int mood; // 1-5
  final int health; // 1-5
  final int fitness; // 1-5
  final int family; // 1-5
  final int fun; // 1-5
  final int spiritual; // 1-5

  WellnessItem({
    required this.id,
    required this.date,
    required this.productivity,
    required this.mood,
    required this.health,
    required this.fitness,
    required this.family,
    required this.fun,
    required this.spiritual,
  });

  WellnessItem copyWith({
    String? id,
    DateTime? date,
    int? productivity,
    int? mood,
    int? health,
    int? fitness,
    int? family,
    int? fun,
    int? spiritual,
  }) {
    return WellnessItem(
      id: id ?? this.id,
      date: date ?? this.date,
      productivity: productivity ?? this.productivity,
      mood: mood ?? this.mood,
      health: health ?? this.health,
      fitness: fitness ?? this.fitness,
      family: family ?? this.family,
      fun: fun ?? this.fun,
      spiritual: spiritual ?? this.spiritual,
    );
  }
}