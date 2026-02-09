import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kapok_app/features/auth/bloc/auth_event.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/map/pages/map_page.dart';
import '../features/teams/pages/teams_page.dart';
import '../features/tasks/pages/tasks_page.dart';
import '../features/profile/pages/profile_page.dart';
import 'about_page.dart';

/// Home page - Main dashboard with navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AboutPage(),
    const MapPage(),
    const TasksPage(),
    const TeamsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
              selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.info_outline),
                  label: AppLocalizations.of(context).about,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.map),
                  label: AppLocalizations.of(context).map,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment),
                  label: AppLocalizations.of(context).tasks,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.group),
                  label: AppLocalizations.of(context).teams,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppLocalizations.of(context).profile,
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(),
          );
        } else {
          // User not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  /// Build floating action button based on current page
  Widget? _buildFloatingActionButton() {
    final theme = Theme.of(context);
    switch (_currentIndex) {
      case 1: // Map page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.add),
        );
      case 2: // Tasks page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.add),
        );
      case 3: // Teams page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-team');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.group_add),
        );
      default:
        return null;
    }
  }
}

/// App drawer for additional navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.drawerTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).disasterReliefCoordination,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context).about),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context).signOut),
            onTap: () {
              Navigator.of(context).pop();
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// Show sign out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.signOut),
        content: Text(localizations.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(localizations.signOut.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
