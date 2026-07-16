import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDueDateNotification(int id, String invoiceNum, DateTime dueDate) async {
    // Schedule notification 24 hours before due date
    final scheduleDate = dueDate.subtract(const Duration(days: 1));
    
    // Only schedule if the date is in the future
    if (scheduleDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Payment Due Reminder',
      'Invoice $invoiceNum is due tomorrow!',
      tz.TZDateTime.from(scheduleDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_date_channel',
          'Due Date Reminders',
          channelDescription: 'Notifications for invoice due dates',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
