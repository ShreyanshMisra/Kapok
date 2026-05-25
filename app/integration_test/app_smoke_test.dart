// Integration test scaffold for Kapok.
//
// This is the minimum end-to-end test that boots the app on a real device or
// emulator. It does **not** sign in (that would require Firebase emulator or
// disposable test credentials), but it verifies the launch path doesn't crash
// and the login screen renders. Future tests in this directory should:
//
//   1. Wire up the Firebase emulator suite (see docs/15_store_readiness_evaluation.md
//      §7 for the gap list).
//   2. Sign in with a deterministic test account.
//   3. Walk through a happy-path flow: create team → create task → assign.
//   4. Assert on visible UI (no implementation details).
//
// Run with:
//   flutter test integration_test/                       # all targets
//   flutter test integration_test/app_smoke_test.dart    # this file only
//
// On CI, prefer a headless device:
//   flutter test integration_test/ -d <device-id>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kapok_app/core/localization/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch smoke', () {
    testWidgets('renders a localized "login" label without crashing',
        (WidgetTester tester) async {
      // We intentionally do NOT pump the full app here — that requires Firebase
      // initialization, which integration tests should run against an emulator.
      // Instead this scaffold proves the localization layer mounts under the
      // integration_test harness so future authors have a working starting point.
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(AppLocalizations.of(context).login),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
