import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/wellness_item.dart';

/// StateNotifier for managing wellness entries with Hive persistence.
class WellnessListNotifier extends StateNotifier<List<WellnessItem>> {
  final Box<WellnessItem> _box;
  WellnessListNotifier()
      : _box = Hive.box<WellnessItem>('wellness'),
        super(Hive.box<WellnessItem>('wellness').values.toList());

  /// Add or update today's wellness entry.
  void upsert(WellnessItem item) {
    _box.put(item.id, item);
    final updated = state.where((e) => e.id != item.id).toList()..add(item);
    state = updated;
  }
}

/// Provider exposing the list of wellness entries.
final wellnessListProvider =
    StateNotifierProvider<WellnessListNotifier, List<WellnessItem>>(
  (ref) => WellnessListNotifier(),
);