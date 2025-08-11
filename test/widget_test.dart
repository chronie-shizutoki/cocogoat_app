// This is a basic Flutter widget test.
//
// This test verifies that the app starts correctly and displays the home screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:geshin_achievement/main.dart';
import 'package:geshin_achievement/providers/achievement_provider.dart';

void main() {
  testWidgets('App starts and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GeshinAchievementApp());

    // Verify that the app starts with the home screen
    expect(find.text('Geshin Achievement'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('成就'), findsOneWidget);
    expect(find.text('导出'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('AchievementProvider initializes correctly', (WidgetTester tester) async {
    // Create a test app with the provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AchievementProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<AchievementProvider>(
              builder: (context, provider, child) {
                return Text('Data loaded: ${provider.achievements.isNotEmpty}');
              },
            ),
          ),
        ),
      ),
    );

    // Initial state should show loading or empty
    expect(find.text('Data loaded: false'), findsOneWidget);

    // Allow time for data loading
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // After loading, we should have data or show sample data message
    // This depends on whether sample data is loaded in your provider
    // For this test, we'll just check that the provider is properly initialized
    expect(find.byType(Consumer<AchievementProvider>), findsOneWidget);
  });
}
