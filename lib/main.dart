import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/models/adapters.dart';
import 'src/models/task.dart';
import 'src/models/meal_item.dart';
import 'src/app.dart';
import 'src/models/communication_item.dart';
import 'src/models/schedule_item.dart';
import 'src/models/appointment_item.dart';
import 'src/models/expense_item.dart';
import 'src/models/note_item.dart';
import 'src/models/goal_item.dart';
import 'src/models/wellness_item.dart';
import 'src/services/notification_service.dart';
import 'src/services/auth_service.dart';
import 'src/providers/auth_provider.dart';
import 'src/models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(MealItemAdapter());
  Hive.registerAdapter(CommunicationTypeAdapter());
  Hive.registerAdapter(CommunicationItemAdapter());
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(AppointmentItemAdapter());
  Hive.registerAdapter(ExpenseItemAdapter());
  Hive.registerAdapter(NoteItemAdapter());
  Hive.registerAdapter(GoalItemAdapter());
  Hive.registerAdapter(WellnessItemAdapter());
  // Open per-user Hive boxes for each dummy user
  for (final user in dummyUsers) {
    await Hive.openBox<Task>('priorities_${user.id}');
    await Hive.openBox<Task>('todos_${user.id}');
    await Hive.openBox<Task>('personal_todos_${user.id}');
    await Hive.openBox<MealItem>('meals_${user.id}');
    await Hive.openBox<CommunicationItem>('communications_${user.id}');
    await Hive.openBox<ScheduleItem>('schedules_${user.id}');
    await Hive.openBox<AppointmentItem>('appointments_${user.id}');
    await Hive.openBox<ExpenseItem>('expenses_${user.id}');
    await Hive.openBox<NoteItem>('notes_${user.id}');
    await Hive.openBox<GoalItem>('goals_${user.id}');
    await Hive.openBox<WellnessItem>('wellness_${user.id}');
    await Hive.openBox('settings_${user.id}');
  }
  // Open box for authentication storage
  final authBox = await Hive.openBox('auth');
  // Initialize notifications
  await NotificationService().init();
  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(AuthService(authBox)),
      ],
      child: const TaskPilotApp(),
    ),
  );
}