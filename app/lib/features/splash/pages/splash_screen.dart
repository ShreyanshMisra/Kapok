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
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryDark : AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isDark
                  ? 'assets/images/icon_tagline/KapokIcon_Dark_Tagline_Wordmark.png'
                  : 'assets/images/icon_tagline/Kapok_Icon_Light_Tagline_Wordmark.png',
              width: 250,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.nature,
                  size: 80,
                  color: isDark ? Colors.white : AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white70 : AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
