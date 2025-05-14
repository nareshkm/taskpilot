import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/appointment_item.dart';

/// StateNotifier for managing appointments with Hive persistence.
class AppointmentListNotifier extends StateNotifier<List<AppointmentItem>> {
  final Box<AppointmentItem> _box;
  AppointmentListNotifier()
      : _box = Hive.box<AppointmentItem>('appointments'),
        super(Hive.box<AppointmentItem>('appointments').values.toList());

  /// Add a new appointment with [title], [start], and [end].
  void add(String title, {required DateTime start, required DateTime end}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = AppointmentItem(id: id, start: start, end: end, title: title);
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove an appointment by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((a) => a.id != id).toList();
  }
}

/// Provider exposing the list of appointments.
final appointmentListProvider =
    StateNotifierProvider<AppointmentListNotifier, List<AppointmentItem>>(
  (ref) => AppointmentListNotifier(),
);