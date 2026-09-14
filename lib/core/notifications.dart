import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: darwinInit,
    macOS: darwinInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<bool> requestNotificationPermission() async {
  final android = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }
  return true;
}

Future<void> scheduleDailyNotification({
  required String title,
  required String body,
  int hour = 7,
  int minute = 0,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'daily_hadith_channel',
    'حديث اليوم',
    channelDescription: 'تذكير يومي بحديث من تحفة الولدان',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
  );
  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
    macOS: darwinDetails,
  );

  // Cancel existing before rescheduling
  await flutterLocalNotificationsPlugin.cancel(42);

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    42,
    title,
    body,
    scheduledDate,
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> cancelDailyNotification() async {
  await flutterLocalNotificationsPlugin.cancel(42);
}

/// Returns a random hadith title and snippet to use in the notification.
Map<String, String> randomHadithNotificationContent(
    List<Map<String, String>> hadiths) {
  final rnd = Random();
  final h = hadiths[rnd.nextInt(hadiths.length)];
  return h;
}

/// Show an immediate test notification (for debugging)
Future<void> showTestNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'daily_hadith_channel',
    'حديث اليوم',
    channelDescription: 'تذكير يومي بحديث من تحفة الولدان',
    importance: Importance.high,
    priority: Priority.high,
  );
  const notificationDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
    'اضغط لقراءة حديث اليوم من تحفة الولدان',
    notificationDetails,
  );
}
