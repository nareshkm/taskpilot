import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/communication_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier for managing communications (calls/emails/texts) with Hive persistence.
class CommunicationListNotifier extends StateNotifier<List<CommunicationItem>> {
  final Box<CommunicationItem> _box;
  final String _ownerId;
  CommunicationListNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a new communication of [type] with [description] scheduled for [date].
  void add(String description,
      {required CommunicationType type, required DateTime date}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = CommunicationItem(
      id: id,
      type: type,
      description: description,
      date: date,
    );
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove a communication by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((i) => i.id != id).toList();
  }

  /// Toggle completed status for a communication by [id].
  void toggleComplete(String id) {
    final updated = state
        .map((i) => i.id == id ? i.copyWith(completed: !i.completed) : i)
        .toList();
    state = updated;
    final item = updated.firstWhere((i) => i.id == id);
    _box.put(item.id, item);
  }

  /// Reorder communications in the list.
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    // Persist new order by rewriting the box
    _box.clear();
    for (final i in list) {
      _box.put(i.id, i);
    }
  }
}

/// Provider exposing the list of communications.
final communicationListProvider =
    StateNotifierProvider<CommunicationListNotifier, List<CommunicationItem>>(
            (ref) {
          final box =   ref.watch(communicationsBoxProvider);
          final ownerId = ref.watch(currentUserProvider).id;
          return CommunicationListNotifier(box, ownerId);
        }
);