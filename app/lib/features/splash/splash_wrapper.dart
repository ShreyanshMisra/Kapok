import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import '../../app/kapok_app.dart';
import '../../core/services/onboarding_service.dart';
import '../onboarding/pages/onboarding_page.dart';

/// Wrapper widget that shows splash screen, then onboarding (if needed), then main app
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _splashComplete = false;
  bool _showOnboarding = false;
  bool _onboardingComplete = false;

  void _onSplashComplete() {
    // Check if user has completed onboarding before
    final hasCompletedOnboarding =
        OnboardingService.instance.hasCompletedOnboarding;

    setState(() {
      _splashComplete = true;
      _showOnboarding = !hasCompletedOnboarding;
      _onboardingComplete = hasCompletedOnboarding;
    });
  }

  void _onOnboardingComplete() async {
    // Mark onboarding as completed
    await OnboardingService.instance.completeOnboarding();

    setState(() {
      _showOnboarding = false;
      _onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show main app after splash and onboarding are complete
    if (_splashComplete && _onboardingComplete) {
      return const KapokApp();
    }

    // Show onboarding after splash is complete (if needed)
    if (_splashComplete && _showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OnboardingPage(
          onComplete: _onOnboardingComplete,
        ),
      );
    }

    // Show splash screen initially
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        onInitializationComplete: _onSplashComplete,
      ),
    );
  }
}
