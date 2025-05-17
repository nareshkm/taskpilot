import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/meal_item.dart';
import '../models/communication_item.dart';
import '../models/schedule_item.dart';
import '../models/appointment_item.dart';
import '../models/expense_item.dart';
import '../models/note_item.dart';
import '../models/goal_item.dart';
import '../models/wellness_item.dart';
import 'auth_provider.dart';

/// Provides the Hive box for the current user's tasks (to-do).
final todosBoxProvider = Provider<Box<Task>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<Task>('todos_${user.id}');
});

/// Provides the Hive box for the current user's priorities.
final prioritiesBoxProvider = Provider<Box<Task>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<Task>('priorities_${user.id}');
});

/// Provides the Hive box for the current user's personal to-dos.
final personalTodosBoxProvider = Provider<Box<Task>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<Task>('personal_todos_${user.id}');
});

/// Provides the Hive box for the current user's meal plan.
final mealsBoxProvider = Provider<Box<MealItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<MealItem>('meals_${user.id}');
});

/// Provides the Hive box for the current user's communications.
final communicationsBoxProvider = Provider<Box<CommunicationItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<CommunicationItem>('communications_${user.id}');
});

/// Provides the Hive box for the current user's daily schedules.
final schedulesBoxProvider = Provider<Box<ScheduleItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<ScheduleItem>('schedules_${user.id}');
});

/// Provides the Hive box for the current user's appointments.
final appointmentsBoxProvider = Provider<Box<AppointmentItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<AppointmentItem>('appointments_${user.id}');
});

/// Provides the Hive box for the current user's expenses.
final expensesBoxProvider = Provider<Box<ExpenseItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<ExpenseItem>('expenses_${user.id}');
});

/// Provides the Hive box for the current user's notes.
final notesBoxProvider = Provider<Box<NoteItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<NoteItem>('notes_${user.id}');
});

/// Provides the Hive box for the current user's goals.
final goalsBoxProvider = Provider<Box<GoalItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<GoalItem>('goals_${user.id}');
});

/// Provides the Hive box for the current user's wellness entries.
final wellnessBoxProvider = Provider<Box<WellnessItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box<WellnessItem>('wellness_${user.id}');
});

/// Provides the Hive box for the current user's settings and onboarding flags.
final settingsBoxProvider = Provider<Box>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box('settings_${user.id}');
});
/// Provides the Hive box for the current user's settings and onboarding flags.
final waterTrackerBoxProvider = Provider<Box>((ref) {
  final user = ref.watch(currentUserProvider);
  return Hive.box('settings_${user.id}');
});
