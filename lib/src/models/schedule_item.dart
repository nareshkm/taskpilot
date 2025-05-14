/// A scheduled event for a specific time period on a given date.
class ScheduleItem {
  /// Unique identifier for the schedule item.
  final String id;
  /// Start date and time of the event.
  final DateTime start;
  /// End date and time of the event.
  final DateTime end;
  /// Title or description of the event.
  final String title;

  ScheduleItem({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
  });

  /// Creates a copy with updated fields.
  ScheduleItem copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
    );
  }
}