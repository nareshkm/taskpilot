/// Represents an appointment with a start and end time and title.
class AppointmentItem {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;

  AppointmentItem({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
  });

  AppointmentItem copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
  }) {
    return AppointmentItem(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
    );
  }
}