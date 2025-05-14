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
  // Open Hive boxes
  await Hive.openBox<Task>('priorities');
  await Hive.openBox<Task>('todos');
  await Hive.openBox<Task>('personal_todos');
  await Hive.openBox<MealItem>('meals');
  await Hive.openBox<CommunicationItem>('communications');
  await Hive.openBox<ScheduleItem>('schedules');
  await Hive.openBox<AppointmentItem>('appointments');
  await Hive.openBox<ExpenseItem>('expenses');
  await Hive.openBox<NoteItem>('notes');
  await Hive.openBox<GoalItem>('goals');
  await Hive.openBox<WellnessItem>('wellness');
  await Hive.openBox('settings');
  // Initialize notifications
  await NotificationService().init();
  runApp(const ProviderScope(child: TaskPilotApp()));
}