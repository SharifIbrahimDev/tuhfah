import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/notifications.dart';
import 'data/providers/hadith_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  
  // Pre-initialize SharedPreferences for Riverpod synchronous override
  final sharedPreferences = await SharedPreferences.getInstance();

  // Ensure daily notification schedule is active if enabled
  final isNotificationsEnabled =
      sharedPreferences.getBool('notifications_enabled') ?? false;
  if (isNotificationsEnabled) {
    final hour = sharedPreferences.getInt('notification_hour') ?? 7;
    final minute = sharedPreferences.getInt('notification_minute') ?? 0;
    try {
      await scheduleDailyNotification(hour: hour, minute: minute);
    } catch (_) {}
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TuhfahApp(),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class TuhfahApp extends ConsumerWidget {
  const TuhfahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'تُحْفَةُ الوِلْدَانِ',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // RTL Arabic layout configurations
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      home: const SplashScreen(),
    );
  }
}
