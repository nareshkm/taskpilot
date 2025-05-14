import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/note_item.dart';

/// StateNotifier for managing notes and staff comments with Hive persistence.
class NoteListNotifier extends StateNotifier<List<NoteItem>> {
  final Box<NoteItem> _box;
  NoteListNotifier()
      : _box = Hive.box<NoteItem>('notes'),
        super(Hive.box<NoteItem>('notes').values.toList());

  /// Add a new note for [date] with [content] and optional [staffComment].
  void add(String content, {required DateTime date, String? staffComment}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NoteItem(
      id: id,
      date: date,
      content: content,
      staffComment: staffComment,
    );
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove a note by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((n) => n.id != id).toList();
  }
}

/// Provider exposing the list of notes.
final noteListProvider =
    StateNotifierProvider<NoteListNotifier, List<NoteItem>>(
  (ref) => NoteListNotifier(),
);