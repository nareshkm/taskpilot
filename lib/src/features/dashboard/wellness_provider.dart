import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/wellness_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier for managing wellness entries with Hive persistence.
class WellnessListNotifier extends StateNotifier<List<WellnessItem>> {
  final Box<WellnessItem> _box;
  final String _ownerId;
  WellnessListNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

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
            (ref) {
          final box =   ref.watch(wellnessBoxProvider);
          final ownerId = ref.watch(currentUserProvider).id;
          return WellnessListNotifier(box, ownerId);
        }
);