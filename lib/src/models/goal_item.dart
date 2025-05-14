/// Model representing a user goal with progress tracking.
class GoalItem {
  final String id;
  final String title;
  final int target;
  final int progress;

  GoalItem({
    required this.id,
    required this.title,
    required this.target,
    this.progress = 0,
  });

  /// Create a copy with updated fields.
  GoalItem copyWith({String? id, String? title, int? target, int? progress}) {
    return GoalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      target: target ?? this.target,
      progress: progress ?? this.progress,
    );
  }
}