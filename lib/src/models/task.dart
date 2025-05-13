/// A simple Task model for use in TaskPilot.
class Task {
  final String id;
  final String title;
  final bool completed;
  /// The date this task is scheduled for
  final DateTime date;
  /// If true, this task repeats on every date
  final bool isRepetitive;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.date,
    this.isRepetitive = false,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? date,
    bool? isRepetitive,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      isRepetitive: isRepetitive ?? this.isRepetitive,
    );
  }
}