import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuhfah/main.dart';
import 'package:tuhfah/data/providers/hadith_provider.dart';

void main() {
  testWidgets('TuhfahApp smoke test - loads home screen', (WidgetTester tester) async {
    // Setup mock values for SharedPreferences before running the test
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Build TuhfahApp inside ProviderScope with overridden preferences
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TuhfahApp(),
      ),
    );

    // Let any asynchronous loading (like parsing hadiths.json) complete
    await tester.pumpAndSettle();

    // Verify that the main title of the app is rendered on the screen
    expect(find.text('تُحْفَتُ الوِلْدَانِ'), findsOneWidget);
  });
}
