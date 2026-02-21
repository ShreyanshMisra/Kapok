import 'package:flutter/material.dart';
import 'package:kapok_app/data/models/team_model.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/signup_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/role_selection_page.dart';
import '../features/teams/pages/teams_page.dart';
import '../features/teams/pages/create_team_page.dart';
import '../features/teams/pages/join_team_page.dart';
import '../features/teams/pages/team_detail_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/profile/pages/edit_profile_page.dart';
import '../features/profile/pages/settings_page.dart';
import '../features/tasks/pages/tasks_page.dart';
import '../features/tasks/pages/create_task_page.dart';
import '../features/tasks/pages/task_detail_page.dart';
import '../features/tasks/pages/edit_task_page.dart';
import '../features/map/pages/map_page.dart';
import '../features/map/pages/map_test_page.dart';
import '../features/map/pages/map_cache_page.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/analytics/pages/analytics_page.dart';
import 'home_page.dart';
import 'about_page.dart';

/// App router for navigation
class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  static const String home = '/home';
  static const String about = '/about';
  static const String teams = '/teams';
  static const String createTeam = '/create-team';
  static const String joinTeam = '/join-team';
  static const String teamDetail = '/team-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String appSettings = '/settings';
  static const String tasks = '/tasks';
  static const String createTask = '/create-task';
  static const String taskDetail = '/task-detail';
  static const String editTask = '/edit-task';
  static const String map = '/map';
  static const String mapTest = '/map-test';
  static const String mapCache = '/map-cache';
  static const String onboarding = '/onboarding';
  static const String analytics = '/analytics';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Handle root path - show login page
    if (settings.name == null || settings.name == '/') {
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: settings,
      );
    }

    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionPage(),
          settings: settings,
        );
      
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      
      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutPage(),
          settings: settings,
        );
      
      case teams:
        return MaterialPageRoute(
          builder: (_) => const TeamsPage(),
          settings: settings,
        );
      
      case createTeam:
        return MaterialPageRoute(
          builder: (_) => const CreateTeamPage(),
          settings: settings,
        );
      
      case joinTeam:
        return MaterialPageRoute(
          builder: (_) => const JoinTeamPage(),
          settings: settings,
        );
      
      case AppRouter.teamDetail:
        final team = settings.arguments as TeamModel?;
        if (team == null) {
          return MaterialPageRoute(
            builder: (_) => const NotFoundPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => TeamDetailPage(team: team),
          settings: settings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );
      
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      
      case tasks:
        return MaterialPageRoute(
          builder: (_) => const TasksPage(),
          settings: settings,
        );
      
      case createTask:
        return MaterialPageRoute(
          builder: (_) => const CreateTaskPage(),
          settings: settings,
        );
      
      case taskDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TaskDetailPage(
            task: args['task'],
            currentUserId: args['currentUserId'],
          ),
          settings: settings,
        );
      
      case editTask:
        final task = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => EditTaskPage(task: task),
          settings: settings,
        );
      
      case map:
        return MaterialPageRoute(
          builder: (_) => const MapPage(),
          settings: settings,
        );

      case mapTest:
        return MaterialPageRoute(
          builder: (_) => const MapTestPage(),
          settings: settings,
        );

      case mapCache:
        return MaterialPageRoute(
          builder: (_) => const MapCachePage(),
          settings: settings,
        );

      case analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsPage(),
          settings: settings,
        );

      case onboarding:
        final onComplete = settings.arguments as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) => OnboardingPage(
            onComplete: onComplete ?? () {},
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: settings,
        );
    }
  }

  /// Get initial route based on authentication status
  static String getInitialRoute(bool isAuthenticated) {
    return isAuthenticated ? home : login;
  }
}

/// 404 Not Found page
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('Page Not Found'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
