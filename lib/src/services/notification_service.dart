import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';

/// Service to schedule local notifications for hydration reminders and daily motivational quotes.
class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service and schedule reminders.
  Future<void> init() async {
    final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = IOSInitializationSettings();
    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
    );
    // Schedule reminders
    _scheduleHydrationReminder();
    _scheduleDailyQuote();
  }

  void _scheduleHydrationReminder() {
    const id = 0;
    const title = 'Hydration Reminder';
    const body = 'Time to drink a glass of water!';
    _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.hourly,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Reminders',
          'Hourly reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
    );
  }

  void _scheduleDailyQuote() {
    const id = 1;
    const channelId = 'quote_channel';
    const channelName = 'Daily Quotes';
    const channelDesc = 'Daily motivational quotes';
    final quotes = [
      'Believe you can and you’re halfway there.',
      'Your limitation—it’s only your imagination.',
      'Push yourself, because no one else is going to do it for you.',
      'Great things never come from comfort zones.',
      'Dream it. Wish it. Do it.',
    ];
    final randomQuote = quotes[Random().nextInt(quotes.length)];
    // Schedule at 9:00 AM every day
    final now = DateTime.now();
    final scheduleTime = Time(9, 0, 0);
    _flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      'Motivational Quote',
      randomQuote,
      scheduleTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
    );
  }
  
  /// Schedule a one-time notification reminder for a task.
  void scheduleTaskReminder(Task task, {int minutesBefore = 15}) {
    final scheduledDate = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      9, // default reminder hour
    ).subtract(Duration(minutes: minutesBefore));
    final now = DateTime.now();
    final notifyTime = scheduledDate.isBefore(now) ? now.add(Duration(seconds: 5)) : scheduledDate;
    _flutterLocalNotificationsPlugin.schedule(
      task.id.hashCode,
      'Upcoming Task',
      task.title,
      notifyTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          'Reminders for scheduled tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
    );
  }

  /// Cancel a previously scheduled task reminder.
  void cancelTaskReminder(String taskId) {
    _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }
  /// Show an immediate notification.
  Future<void> showSimpleNotification({required String id, required String title, required String body}) async {
    await _flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
    );
  }
}