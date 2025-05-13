import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// StateNotifier for tracking daily water intake count (0-8 cups) with Hive persistence.
class WaterTrackerNotifier extends StateNotifier<int> {
  final Box _box;
  WaterTrackerNotifier()
      : _box = Hive.box('settings'),
        super(_initCount());

  static int _initCount() {
    final box = Hive.box('settings');
    return box.get('waterCount', defaultValue: 0) as int;
  }

  /// Set water count between 0 and 8.
  void setCount(int count) {
    if (count < 0) count = 0;
    if (count > 8) count = 8;
    state = count;
    _box.put('waterCount', state);
  }

  /// Increment water count by 1.
  void increment() {
    if (state < 8) {
      state = state + 1;
      _box.put('waterCount', state);
    }
  }

  /// Decrement water count by 1.
  void decrement() {
    if (state > 0) {
      state = state - 1;
      _box.put('waterCount', state);
    }
  }

  /// Reset water count to zero.
  void reset() {
    state = 0;
    _box.put('waterCount', state);
  }
}

/// Provider exposing the current water intake count.
final waterTrackerProvider =
    StateNotifierProvider<WaterTrackerNotifier, int>((ref) {
  return WaterTrackerNotifier();
});