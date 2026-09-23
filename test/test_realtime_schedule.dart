import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuhfah/core/notifications.dart';

void main() {
  AndroidFlutterLocalNotificationsPlugin.registerWith();
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final List<Map<String, dynamic>> scheduledAlarms = [];

  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    scheduledAlarms.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'initialize') {
        return true;
      } else if (methodCall.method == 'zonedSchedule') {
        final args = Map<String, dynamic>.from(methodCall.arguments as Map);
        scheduledAlarms.removeWhere((a) => a['id'] == args['id']);
        scheduledAlarms.add(args);
        return true;
      } else if (methodCall.method == 'cancel') {
        int? id;
        if (methodCall.arguments is int) {
          id = methodCall.arguments as int;
        } else if (methodCall.arguments is Map) {
          id = (methodCall.arguments as Map)['id'] as int?;
        }
        if (id != null) {
          scheduledAlarms.removeWhere((a) => a['id'] == id);
        } else {
          scheduledAlarms.clear();
        }
        return true;
      } else if (methodCall.method == 'pendingNotificationRequests') {
        return scheduledAlarms;
      } else if (methodCall.method == 'canScheduleExactNotifications') {
        return true;
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (MethodCall call) async {
        return 'Africa/Algiers';
      },
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    scheduledAlarms.clear();
  });

  test('Schedule daily notification sets correct target hour and minute', () async {
    const targetHour = 15;
    const targetMinute = 47;

    final result = await scheduleDailyNotification(
      hour: targetHour,
      minute: targetMinute,
      title: 'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
      body: 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»',
    );

    expect(result.success, isTrue);
    expect(result.isExact, isTrue);
    expect(result.scheduledDate, isNotNull);
    expect(result.scheduledDate!.hour, equals(15));
    expect(result.scheduledDate!.minute, equals(47));
    expect(scheduledAlarms.length, equals(1));

    final alarm = scheduledAlarms.first;
    expect(alarm['id'], equals(kDailyNotificationId));
    expect(alarm['title'], contains('تُحْفَةُ الوِلْدَانِ'));
  });

  test('Pending notification queue verification', () async {
    await scheduleDailyNotification(
      hour: 7,
      minute: 0,
    );

    final pending = await getPendingNotificationRequests();
    expect(pending.isNotEmpty, isTrue);
    expect(pending.first.id, equals(kDailyNotificationId));
  });

  test('Daily Notification Next Trigger Calculation', () async {
    final nextTime = getNextDailyNotificationDateTime(7, 30);
    expect(nextTime, isNotNull);
    expect(nextTime.hour, equals(7));
    expect(nextTime.minute, equals(30));
    expect(nextTime.isAfter(tz.TZDateTime.now(tz.local)), isTrue);
  });
}
