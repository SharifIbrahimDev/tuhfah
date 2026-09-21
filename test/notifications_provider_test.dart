import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuhfah/data/providers/hadith_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notifications Provider Tests', () {
    test('NotificationsNotifier defaults to true when key is absent', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifier = NotificationsNotifier(prefs);
      expect(notifier.state, true);
    });

    test('NotificationsNotifier respects saved false value', () async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      final prefs = await SharedPreferences.getInstance();

      final notifier = NotificationsNotifier(prefs);
      expect(notifier.state, false);
    });

    test('NotificationsNotifier updates state and saves to preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifier = NotificationsNotifier(prefs);
      await notifier.setEnabled(false);
      expect(notifier.state, false);
      expect(prefs.getBool('notifications_enabled'), false);

      await notifier.setEnabled(true);
      expect(notifier.state, true);
      expect(prefs.getBool('notifications_enabled'), true);
    });

    test('NotificationTimeNotifier defaults to 7:00 AM and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final notifier = NotificationTimeNotifier(prefs);
      expect(notifier.state, const TimeOfDay(hour: 7, minute: 0));

      await notifier.setTime(const TimeOfDay(hour: 8, minute: 30));
      expect(notifier.state, const TimeOfDay(hour: 8, minute: 30));
      expect(prefs.getInt('notification_hour'), 8);
      expect(prefs.getInt('notification_minute'), 30);
    });
  });
}
