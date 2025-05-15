import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();

    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
    );

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
          channelDescription: 'Hourly reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local).isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.from(scheduledTime.add(Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduledTime, tz.local);

    _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Motivational Quote',
      randomQuote,
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Optional, for daily schedules
    );

  }

  void scheduleTaskReminder(Task task, {int minutesBefore = 15}) {
    final scheduledDate = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      9,
    ).subtract(Duration(minutes: minutesBefore));

    final now = DateTime.now();
    final notifyTime = scheduledDate.isBefore(now) ? now.add(Duration(seconds: 5)) : scheduledDate;
    final tzNotifyTime = tz.TZDateTime.from(notifyTime, tz.local);

    _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Upcoming Task',
      task.title,
      tzNotifyTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Reminders for scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Optional, for daily schedules
    );
  }

  void cancelTaskReminder(String taskId) {
    _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<void> showSimpleNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
