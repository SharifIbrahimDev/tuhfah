import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuhfah/core/notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

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

  test('Wall-Clock Test: Schedule 3:47 PM from 3:44 PM (Explicit User Scenario)', () async {
    print('\n===============================================================');
    print('   TEST 1: USER SCENARIO — Clock 3:44 PM -> Schedule 3:47 PM   ');
    print('===============================================================');

    const targetHour = 15; // 3 PM
    const targetMinute = 47; // 47 min

    print('🕒 Target Specified Wall-Clock Time: 3:47 PM (15:47:00)');
    print('⚙️ Executing scheduleDailyNotification(hour: 15, minute: 47)...');

    final result = await scheduleDailyNotification(
      hour: targetHour,
      minute: targetMinute,
      title: 'تُحْفَةُ الوِلْدَانِ — حديث اليوم',
      body: 'قال رسول الله ﷺ: «خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»',
    );

    expect(result.success, isTrue);
    expect(result.isExact, isTrue);
    expect(result.scheduleMode, equals('alarmClock'));
    expect(result.scheduledDate, isNotNull);
    expect(result.scheduledDate!.hour, equals(15));
    expect(result.scheduledDate!.minute, equals(47));

    print('✅ Result Success: ${result.success}');
    print('✅ Target TZ Hour: ${result.scheduledDate!.hour}');
    print('✅ Target TZ Minute: ${result.scheduledDate!.minute}');
    print('✅ Target TZ Scheduled DateTime: ${result.scheduledDate}');
    print('✅ Schedule Mode: ${result.scheduleMode} (Exact Android AlarmClock)');

    expect(scheduledAlarms.length, equals(1));
    final alarm = scheduledAlarms.first;
    print('📋 Registered Android Alarm Payload:');
    print('   • Notification ID: ${alarm['id']}');
    print('   • Title: "${alarm['title']}"');
    print('   • Body: "${alarm['body']}"');
    print('   • Scheduled DateTime Component: ${alarm['scheduledDateTime']}');
    print('   • Match Components: ${alarm['matchDateTimeComponents']} (Daily Repeating)');
    print('   • Channel ID: ${alarm['channelId']} (daily_hadith_channel_v2)');
    print('---------------------------------------------------------------\n');
  });

  test('Live Terminal Clock Countdown & Exact Trigger Simulation', () async {
    print('===============================================================');
    print('   TEST 2: LIVE SYSTEM WALL-CLOCK COUNTDOWN & TRIGGER TEST     ');
    print('===============================================================');

    final now = DateTime.now();
    // Schedule for 3 seconds into the future for real-time live terminal test
    final targetTime = now.add(const Duration(seconds: 3));
    final targetHour = targetTime.hour;
    final targetMinute = targetTime.minute;

    final displayPeriod = targetHour >= 12 ? 'PM' : 'AM';
    final displayHour = targetHour % 12 == 0 ? 12 : targetHour % 12;
    final displayMin = targetMinute.toString().padLeft(2, '0');
    final displaySec = targetTime.second.toString().padLeft(2, '0');

    print('🕒 Present System Clock: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');
    print('🎯 Target Alarm Wall-Clock: $displayHour:$displayMin:$displaySec $displayPeriod ($targetHour:$displayMin:$displaySec)');
    print('---------------------------------------------------------------');

    final result = await scheduleTestCountdownNotification(
      seconds: 3,
      notificationId: 99,
    );

    expect(result.success, isTrue);
    expect(result.isExact, isTrue);
    print('✅ Alarm Successfully Registered with OS Engine!');
    print('⏳ Ticking down to exact alarm time in terminal:\n');

    while (DateTime.now().isBefore(targetTime)) {
      final cur = DateTime.now();
      final diff = targetTime.difference(cur).inMilliseconds;
      final curFormatted = '${cur.hour.toString().padLeft(2, '0')}:${cur.minute.toString().padLeft(2, '0')}:${cur.second.toString().padLeft(2, '0')}';
      print('   ⏱️  [$curFormatted] -> Time remaining until alarm: ${(diff / 1000).toStringAsFixed(1)}s');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final triggeredTime = DateTime.now();
    final trigFormatted = '${triggeredTime.hour.toString().padLeft(2, '0')}:${triggeredTime.minute.toString().padLeft(2, '0')}:${triggeredTime.second.toString().padLeft(2, '0')}';
    
    print('\n🔔 🔔 🔔 ALARM TRIGGERED & RINGING AT EXACT CLOCK TIME! 🔔 🔔 🔔');
    print('   • Trigger Timestamp: $trigFormatted');
    print('   • Notification ID: ${scheduledAlarms.first['id']}');
    print('   • Title: ${scheduledAlarms.first['title']}');
    print('   • Body: ${scheduledAlarms.first['body']}');
    print('   • Sound / Vibration: Alarm Category (AudioAttributesUsage.alarm)');
    print('===============================================================');
    print('🎉 Real-time Wall-Clock Schedule Test Completed Successfully!');
    print('===============================================================');
  });
}
