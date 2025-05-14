/// Represents a note or staff comment for a specific date.
class NoteItem {
  final String id;
  final DateTime date;
  final String content;
  final String? staffComment;

  NoteItem({
    required this.id,
    required this.date,
    required this.content,
    this.staffComment,
  });

  NoteItem copyWith({
    String? id,
    DateTime? date,
    String? content,
    String? staffComment,
  }) {
    return NoteItem(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      staffComment: staffComment ?? this.staffComment,
    );
  }
}