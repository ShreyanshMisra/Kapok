import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Static splash screen showing Kapok logo
/// Displays while the app initializes
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Complete initialization after minimum display time
    // Reduced from 3000ms to 1500ms since we no longer need animation time
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kapok icon with tagline wordmark
            Image.asset(
              'assets/images/icon_tagline/Kapok_Icon_Dark_Tagline_Wordmark.png',
              width: 250,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.nature,
                  size: 80,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(height: 48),
            // Simple loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
