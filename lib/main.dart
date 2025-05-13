import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/models/adapters.dart';
import 'src/models/task.dart';
import 'src/models/meal_item.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(MealItemAdapter());
  // Open Hive boxes
  await Hive.openBox<Task>('priorities');
  await Hive.openBox<Task>('todos');
  await Hive.openBox<MealItem>('meals');
  await Hive.openBox('settings');
  runApp(const ProviderScope(child: TaskPilotApp()));
}