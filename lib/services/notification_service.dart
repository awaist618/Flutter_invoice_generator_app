import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

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
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleInvoiceReminders(int hashCode, String invoiceNum, DateTime dueDate) async {
    // Generate unique IDs for different types of reminders for the same invoice
    final int id24h = hashCode;
    final int id1h = hashCode + 1000000; // Offset to avoid collisions

    final now = DateTime.now();

    // 1. Reminder 24 hours before
    final date24h = dueDate.subtract(const Duration(hours: 24));
    if (date24h.isAfter(now)) {
      await _schedule(
        id24h,
        'Upcoming Payment Reminder',
        'Invoice $invoiceNum is due in 24 hours. Please ensure the client is notified for timely payment.',
        date24h,
      );
    }

    // 2. Reminder 1 hour before
    final date1h = dueDate.subtract(const Duration(hours: 1));
    if (date1h.isAfter(now)) {
      await _schedule(
        id1h,
        'Urgent: Final Payment Reminder',
        'Invoice $invoiceNum will be overdue in 1 hour. Consider a final follow-up call with the customer.',
        date1h,
      );
    }
  }

  Future<void> _schedule(int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'invoice_reminders_channel',
          'Invoice Reminders',
          channelDescription: 'Professional reminders for invoice due dates',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllReminders(int hashCode) async {
    await flutterLocalNotificationsPlugin.cancel(hashCode);
    await flutterLocalNotificationsPlugin.cancel(hashCode + 1000000);
  }
}
