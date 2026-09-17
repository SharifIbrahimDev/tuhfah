import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String kNotificationChannelId = 'daily_hadith_channel';
const String kNotificationChannelName = 'حديث اليوم';
const String kNotificationChannelDescription =
    'تذكير يومي بحديث نبوي شريف من كتاب تحفة الولدان';
const int kDailyNotificationId = 42;

/// Initializes local notifications, discovers device timezone, and registers Android channel
Future<void> initNotifications() async {
  // Initialize timezone database
  tz.initializeTimeZones();

  // Set device local timezone
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    final String currentTimeZone = tzInfo.identifier;
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (_) {
    // If timezone lookup fails, default to UTC location gracefully
  }

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

  // Pre-create notification channel with high priority on Android
  if (Platform.isAndroid) {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const androidChannel = AndroidNotificationChannel(
        kNotificationChannelId,
        kNotificationChannelName,
        description: kNotificationChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(androidChannel);
    }
  }
}

/// Requests both notification permission and exact alarm permission where needed
Future<bool> requestNotificationPermission() async {
  bool granted = true;

  if (Platform.isAndroid) {
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notifGranted = await android.requestNotificationsPermission();
      granted = notifGranted ?? false;

      // Request exact alarms permission on Android 12+ (API 31+)
      try {
        await android.requestExactAlarmsPermission();
      } catch (_) {}
    }
  } else if (Platform.isIOS) {
    final ios = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final notifGranted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = notifGranted ?? false;
    }
  }

  return granted;
}

/// Schedules the daily hadith notification at the given hour and minute (local device time)
Future<void> scheduleDailyNotification({
  int hour = 7,
  int minute = 0,
  String? title,
  String? body,
}) async {
  String notifTitle = title ?? 'تُحْفَةُ الوِلْدَانِ — حديث اليوم';
  String notifBody =
      body ?? 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»';

  if (title == null || body == null) {
    try {
      final content = await getTodayHadithNotificationContent();
      notifTitle = content['title'] ?? notifTitle;
      notifBody = content['body'] ?? notifBody;
    } catch (_) {}
  }

  const androidDetails = AndroidNotificationDetails(
    kNotificationChannelId,
    kNotificationChannelName,
    channelDescription: kNotificationChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
    category: AndroidNotificationCategory.reminder,
    visibility: NotificationVisibility.public,
    playSound: true,
    enableVibration: true,
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

  // Cancel existing scheduled notification before setting a new one
  await flutterLocalNotificationsPlugin.cancel(kDailyNotificationId);

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  // If time already passed for today, schedule for tomorrow
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // Attempt exact schedule first; fallback to inexact if OS restricts exact alarms
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      kDailyNotificationId,
      notifTitle,
      notifBody,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (_) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      kDailyNotificationId,
      notifTitle,
      notifBody,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

/// Cancels the daily scheduled notification
Future<void> cancelDailyNotification() async {
  await flutterLocalNotificationsPlugin.cancel(kDailyNotificationId);
}

/// Shows an immediate test notification to verify delivery and sound/vibration
Future<void> showTestNotification({String? title, String? body}) async {
  const androidDetails = AndroidNotificationDetails(
    kNotificationChannelId,
    kNotificationChannelName,
    channelDescription: kNotificationChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''),
    playSound: true,
    enableVibration: true,
  );
  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title ?? 'تُحْفَةُ الوِلْدَانِ — تجربة الإشعار',
    body ?? 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ» — يعمل التنبيه بنجاح!',
    notificationDetails,
  );
}

/// Dynamically retrieves a rotating Hadith for today's notification
Future<Map<String, String>> getTodayHadithNotificationContent() async {
  try {
    final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    if (jsonList.isNotEmpty) {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final index = dayOfYear % jsonList.length;
      final hadith = jsonList[index];
      final title = hadith['title'] ?? 'حديث اليوم';
      final text = (hadith['text'] as String? ?? '')
          .replaceAll('«', '')
          .replaceAll('»', '')
          .replaceAll('"', '')
          .trim();

      final narrator = (hadith['narrator'] as String? ?? '').trim();
      final previewText = text.isNotEmpty ? '«$text»' : narrator;

      return {
        'title': 'تُحْفَةُ الوِلْدَانِ — $title',
        'body': previewText.length > 180
            ? '${previewText.substring(0, 180)}...'
            : previewText,
      };
    }
  } catch (_) {}

  return {
    'title': 'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
    'body': 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»',
  };
}
