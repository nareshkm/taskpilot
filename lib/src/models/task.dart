/// A simple Task model for use in TaskPilot.
class Task {
  final String id;
  final String title;
  final bool completed;
  /// The date this task is scheduled for
  final DateTime date;
  /// If true, this task repeats on every date
  final bool isRepetitive;
  /// Owner of the task
  final String ownerId;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.date,
    this.isRepetitive = false,
    required this.ownerId,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? date,
    bool? isRepetitive,
    String? ownerId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      isRepetitive: isRepetitive ?? this.isRepetitive,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}