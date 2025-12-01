import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kapok_app/features/map/pages/map_page.dart';

void main() {
  testWidgets('Status card shows offline text when bubble active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapStatusCard(
            regionName: 'Test Bubble',
            isOffline: true,
            progress: null,
          ),
        ),
      ),
    );

    expect(find.text('Test Bubble'), findsOneWidget);
    expect(find.text('Offline bubble active'), findsOneWidget);
  });

  testWidgets('Status card shows progress when refreshing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapStatusCard(
            regionName: 'Test Bubble',
            isOffline: false,
            progress: 0.5,
          ),
        ),
      ),
    );

    expect(find.textContaining('Refreshing 50%'), findsOneWidget);
  });
}
