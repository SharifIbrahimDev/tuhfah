import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuhfah/core/notifications.dart';

void main() {
  AndroidFlutterLocalNotificationsPlugin.registerWith();
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> log = <MethodCall>[];
  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'initialize') {
        return true;
      } else if (methodCall.method == 'pendingNotificationRequests') {
        return <Map<String, Object?>>[
          {
            'id': kDailyNotificationId,
            'title': 'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
            'body': 'قال رسول الله ﷺ...',
            'payload': '',
          }
        ];
      } else if (methodCall.method == 'canScheduleExactNotifications') {
        return true;
      } else if (methodCall.method == 'requestNotificationsPermission') {
        return true;
      } else if (methodCall.method == 'requestExactAlarmsPermission') {
        return true;
      } else if (methodCall.method == 'createNotificationChannel') {
        return true;
      } else if (methodCall.method == 'cancel') {
        return true;
      } else if (methodCall.method == 'zonedSchedule') {
        return true;
      }
      return null;
    });

    // Mock flutter_timezone method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (MethodCall call) async {
        if (call.method == 'getLocalTimezone') {
          return 'Africa/Algiers';
        }
        return 'UTC';
      },
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    log.clear();
  });

  group('Notification Scheduling Terminal Tests', () {
    test('initNotifications initializes plugin and registers channel', () async {
      await initNotifications();
      expect(
        log.any((c) => c.method == 'initialize'),
        isTrue,
      );
    });

    test('scheduleDailyNotification schedules daily notification successfully', () async {
      log.clear();
      final result = await scheduleDailyNotification(hour: 7, minute: 30);

      expect(result.success, isTrue);
      expect(result.scheduledDate, isNotNull);
      expect(
        log.any((c) => c.method == 'zonedSchedule'),
        isTrue,
      );

      final scheduleCall = log.firstWhere((c) => c.method == 'zonedSchedule');
      final args = scheduleCall.arguments as Map;
      expect(args['id'], kDailyNotificationId);
      expect(args['title'], contains('تُحْفَةُ الوِلْدَانِ'));
    });

    test('scheduleTestCountdownNotification schedules 10s countdown successfully', () async {
      log.clear();
      final result = await scheduleTestCountdownNotification(
        seconds: 10,
        notificationId: kTestTenSecondsNotificationId,
      );

      expect(result.success, isTrue);
      expect(result.scheduledDate, isNotNull);
      expect(
        log.any((c) => c.method == 'zonedSchedule'),
        isTrue,
      );

      final scheduleCall = log.firstWhere((c) => c.method == 'zonedSchedule');
      final args = scheduleCall.arguments as Map;
      expect(args['id'], kTestTenSecondsNotificationId);
      expect(args['title'], contains('١٠ ثوانٍ'));
    });

    test('scheduleTestCountdownNotification schedules 60s countdown successfully', () async {
      log.clear();
      final result = await scheduleTestCountdownNotification(
        seconds: 60,
        notificationId: kTestScheduledNotificationId,
      );

      expect(result.success, isTrue);
      expect(result.scheduledDate, isNotNull);
      expect(
        log.any((c) => c.method == 'zonedSchedule'),
        isTrue,
      );

      final scheduleCall = log.firstWhere((c) => c.method == 'zonedSchedule');
      final args = scheduleCall.arguments as Map;
      expect(args['id'], kTestScheduledNotificationId);
      expect(args['title'], contains('٦٠ ثانية'));
    });

    test('getPendingNotificationRequests parses pending notifications list', () async {
      final list = await getPendingNotificationRequests();
      expect(list.length, 1);
      expect(list.first.id, kDailyNotificationId);
      expect(list.first.title, contains('حديث اليوم'));
    });

    test('canScheduleExactAlarms checks exact alarm permission on Android', () async {
      final canExact = await canScheduleExactAlarms();
      expect(canExact, isTrue);
    });
  });
}
