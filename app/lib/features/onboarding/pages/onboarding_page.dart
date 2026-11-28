import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/onboarding_slide.dart';
import '../../../core/localization/app_localizations.dart';

/// Onboarding page with introduction slides for first-time users
class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingSlideData> get _slides {
    final l = AppLocalizations.of(context);
    return [
      OnboardingSlideData(
      icon: Icons.medical_services,
      iconColor: AppColors.medical,
      title: l.onboardingWelcomeTitle,
      description:
          l.onboardingWelcomeBody,
      backgroundColor: AppColors.primary,
    ),
      OnboardingSlideData(
      icon: Icons.cloud_off,
      iconColor: AppColors.online,
      title: l.onboardingOfflineTitle,
      description:
          l.onboardingOfflineBody,
      backgroundColor: AppColors.primaryDark,
    ),
      OnboardingSlideData(
      icon: Icons.groups,
      iconColor: AppColors.teamLeader,
      title: l.onboardingTeamsTitle,
      description:
          l.onboardingTeamsBody,
      backgroundColor: AppColors.primary,
    ),
      OnboardingSlideData(
      icon: Icons.task_alt,
      iconColor: AppColors.success,
      title: l.onboardingTasksTitle,
      description:
          l.onboardingTasksBody,
      backgroundColor: AppColors.primaryDark,
    ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slides[_currentPage].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  AppLocalizations.of(context).skip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(data: _slides[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? AppLocalizations.of(context).getStarted
                        : AppLocalizations.of(context).next,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Data class for onboarding slide content
class OnboardingSlideData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Color backgroundColor;

  const OnboardingSlideData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}
