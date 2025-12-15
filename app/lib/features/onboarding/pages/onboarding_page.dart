import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/onboarding_slide.dart';

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

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      icon: Icons.medical_services,
      iconColor: AppColors.medical,
      title: 'Welcome to Kapok',
      description:
          'Coordinate disaster relief efforts with your team. Manage tasks, track progress, and respond to emergencies efficiently.',
      backgroundColor: AppColors.primary,
    ),
    OnboardingSlideData(
      icon: Icons.cloud_off,
      iconColor: AppColors.online,
      title: 'Works Completely Offline',
      description:
          'No internet? No problem. Create tasks, manage teams, and coordinate relief efforts even without connectivity. Everything syncs automatically when you reconnect.',
      backgroundColor: AppColors.primaryDark,
    ),
    OnboardingSlideData(
      icon: Icons.groups,
      iconColor: AppColors.teamLeader,
      title: 'Team Coordination',
      description:
          'Create teams with unique join codes. Assign roles, manage members, and keep everyone synchronized on priorities and responsibilities.',
      backgroundColor: AppColors.primary,
    ),
    OnboardingSlideData(
      icon: Icons.task_alt,
      iconColor: AppColors.success,
      title: 'Smart Task Management',
      description:
          'Create location-based tasks with priorities and due dates. Assign to team members, track status, and visualize everything on an interactive map.',
      backgroundColor: AppColors.primaryDark,
    ),
  ];

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
                child: const Text(
                  'Skip',
                  style: TextStyle(
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
                        ? 'Get Started'
                        : 'Next',
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
