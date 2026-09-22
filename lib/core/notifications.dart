import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String kNotificationChannelId = 'daily_hadith_channel_v2';
const String kNotificationChannelName = 'حديث اليوم (تنبيه دقيق)';
const String kNotificationChannelDescription =
    'تذكير يومي بحديث نبوي شريف من كتاب تحفة الولدان في موعده المحدد بدقة';
const int kDailyNotificationId = 42;
const int kTestScheduledNotificationId = 99;
const int kTestTenSecondsNotificationId = 98;

/// Model to return the result of a scheduling operation
class ScheduleResult {
  final bool success;
  final tz.TZDateTime? scheduledDate;
  final String? errorMessage;
  final bool isExact;
  final String scheduleMode;

  const ScheduleResult({
    required this.success,
    this.scheduledDate,
    this.errorMessage,
    this.isExact = false,
    this.scheduleMode = '',
  });
}

/// Configures and synchronizes local device timezone with the timezone database
Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();

  String? timeZoneName;
  try {
    final dynamic tzResult = await FlutterTimezone.getLocalTimezone()
        .timeout(const Duration(seconds: 2));
    if (tzResult is String) {
      timeZoneName = tzResult.trim();
    } else if (tzResult != null) {
      try {
        timeZoneName = (tzResult as dynamic).identifier?.toString().trim() ??
            tzResult.toString().trim();
      } catch (_) {
        timeZoneName = tzResult.toString().trim();
      }
    }
  } catch (_) {}

  // 1. Try matching location by IANA identifier
  if (timeZoneName != null && timeZoneName.isNotEmpty) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      return;
    } catch (_) {}

    // Try sanitizing standard GMT/UTC strings
    try {
      final sanitized = timeZoneName
          .replaceAll('GMT', 'Etc/GMT')
          .replaceAll('UTC', 'Etc/GMT');
      tz.setLocalLocation(tz.getLocation(sanitized));
      return;
    } catch (_) {}
  }

  // 2. Fallback: match by local device UTC offset
  try {
    final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == offsetMs) {
        tz.setLocalLocation(loc);
        return;
      }
    }
  } catch (_) {}

  // 3. Final Fallback: UTC
  try {
    tz.setLocalLocation(tz.getLocation('UTC'));
  } catch (_) {}
}

/// Initializes local notifications, discovers device timezone, and registers Android channel
Future<void> initNotifications() async {
  await _configureLocalTimeZone();

  const androidInit = AndroidInitializationSettings('ic_launcher');
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

  // Pre-create high priority notification channel on Android
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
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await androidPlugin.createNotificationChannel(androidChannel);
    }
  }
}

/// Checks if exact alarms are permitted on Android (API 31+)
Future<bool> canScheduleExactAlarms() async {
  if (!Platform.isAndroid) return true;
  try {
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final canExact = await android.canScheduleExactNotifications();
      return canExact ?? false;
    }
  } catch (_) {}
  return false;
}

/// Opens the system settings screen for exact alarms permission
Future<bool> openExactAlarmSettings() async {
  if (!Platform.isAndroid) return true;
  try {
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final result = await android.requestExactAlarmsPermission();
      return result ?? false;
    }
  } catch (_) {}
  return false;
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

      // Check exact alarm permission
      try {
        final canScheduleExact = await android.canScheduleExactNotifications() ?? false;
        if (!canScheduleExact) {
          await android.requestExactAlarmsPermission();
        }
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

/// Returns NotificationDetails configured for maximum visibility, sound, and wake-lock
NotificationDetails _buildNotificationDetails({
  required String title,
  required String body,
  String summary = 'حديث اليوم',
}) {
  final androidDetails = AndroidNotificationDetails(
    kNotificationChannelId,
    kNotificationChannelName,
    channelDescription: kNotificationChannelDescription,
    importance: Importance.max,
    priority: Priority.max,
    icon: 'ic_stat_hadith',
    styleInformation: BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: summary,
    ),
    category: AndroidNotificationCategory.alarm,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    visibility: NotificationVisibility.public,
    channelShowBadge: true,
    playSound: true,
    enableVibration: true,
  );

  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    interruptionLevel: InterruptionLevel.timeSensitive,
  );

  return NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
    macOS: darwinDetails,
  );
}

/// Computes the exact next occurrence of the daily notification
tz.TZDateTime getNextDailyNotificationDateTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (scheduledDate.isBefore(now) || scheduledDate.difference(now).inSeconds <= 5) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

/// Schedules the daily hadith notification at the given hour and minute (local device time)
Future<ScheduleResult> scheduleDailyNotification({
  int hour = 7,
  int minute = 0,
  String? title,
  String? body,
}) async {
  await _configureLocalTimeZone();

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

  final notificationDetails = _buildNotificationDetails(
    title: notifTitle,
    body: notifBody,
    summary: 'حديث اليوم',
  );

  // Cancel any existing daily notification
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

  // If the time already passed today (or is within 5 seconds), schedule for tomorrow
  if (scheduledDate.isBefore(now) || scheduledDate.difference(now).inSeconds <= 5) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // Tier 1: Try alarmClock (true exact alarm)
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      kDailyNotificationId,
      notifTitle,
      notifBody,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return ScheduleResult(
      success: true,
      scheduledDate: scheduledDate,
      isExact: true,
      scheduleMode: 'alarmClock',
    );
  } catch (e1) {
    // Tier 2: Try exactAllowWhileIdle
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
      return ScheduleResult(
        success: true,
        scheduledDate: scheduledDate,
        isExact: true,
        scheduleMode: 'exactAllowWhileIdle',
      );
    } catch (e2) {
      // Tier 3: Try standard exact
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          kDailyNotificationId,
          notifTitle,
          notifBody,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return ScheduleResult(
          success: true,
          scheduledDate: scheduledDate,
          isExact: true,
          scheduleMode: 'exact',
        );
      } catch (e3) {
        // Tier 4: Fallback to inexactAllowWhileIdle
        try {
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
          return ScheduleResult(
            success: true,
            scheduledDate: scheduledDate,
            isExact: false,
            scheduleMode: 'inexactAllowWhileIdle',
          );
        } catch (e4) {
          return ScheduleResult(
            success: false,
            errorMessage: e4.toString(),
          );
        }
      }
    }
  }
}

/// Schedules a test countdown notification with seconds precision
Future<ScheduleResult> scheduleTestCountdownNotification({
  int seconds = 60,
  int notificationId = kTestScheduledNotificationId,
}) async {
  await _configureLocalTimeZone();

  // Create target date safely derived from device DateTime.now()
  final targetDateTime = DateTime.now().add(Duration(seconds: seconds));
  final targetTime = tz.TZDateTime.from(targetDateTime, tz.local);

  final title = seconds == 10
      ? 'تُحْفَةُ الوِلْدَانِ — اختبار التنبيه (١٠ ثوانٍ)'
      : 'تُحْفَةُ الوِلْدَانِ — اختبار التنبيه (٦٠ ثانية)';
  const body =
      'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ» — وصلك التنبيه المجدول بنجاح تام!';

  final notificationDetails = _buildNotificationDetails(
    title: title,
    body: body,
    summary: 'تنبيه اختباري مجدول',
  );

  await flutterLocalNotificationsPlugin.cancel(notificationId);

  // Tier 1: alarmClock (highest priority Android alarm)
  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      targetTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return ScheduleResult(
      success: true,
      scheduledDate: targetTime,
      isExact: true,
      scheduleMode: 'alarmClock',
    );
  } catch (e1) {
    // Tier 2: exactAllowWhileIdle
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        targetTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return ScheduleResult(
        success: true,
        scheduledDate: targetTime,
        isExact: true,
        scheduleMode: 'exactAllowWhileIdle',
      );
    } catch (e2) {
      // Tier 3: exact
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          targetTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        return ScheduleResult(
          success: true,
          scheduledDate: targetTime,
          isExact: true,
          scheduleMode: 'exact',
        );
      } catch (e3) {
        // Tier 4: inexact fallback
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            title,
            body,
            targetTime,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          return ScheduleResult(
            success: true,
            scheduledDate: targetTime,
            isExact: false,
            scheduleMode: 'inexactAllowWhileIdle',
          );
        } catch (e4) {
          return ScheduleResult(
            success: false,
            errorMessage: e4.toString(),
          );
        }
      }
    }
  }
}

/// Returns list of all currently registered pending notifications
Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
  try {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  } catch (_) {
    return [];
  }
}

/// Returns the count of currently registered pending notifications
Future<int> getPendingNotificationCount() async {
  final list = await getPendingNotificationRequests();
  return list.length;
}

/// Cancels the daily scheduled notification
Future<void> cancelDailyNotification() async {
  await flutterLocalNotificationsPlugin.cancel(kDailyNotificationId);
}

/// Shows an immediate test notification to verify delivery and sound/vibration
Future<void> showTestNotification({String? title, String? body}) async {
  final testTitle = title ?? 'تُحْفَةُ الوِلْدَانِ — تجربة الإشعار';
  final testBody = body ??
      'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ» — يعمل التنبيه بنجاح!';

  final notificationDetails = _buildNotificationDetails(
    title: testTitle,
    body: testBody,
    summary: 'تجربة الإشعار الفوري',
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    testTitle,
    testBody,
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
