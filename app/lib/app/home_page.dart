import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kapok_app/features/auth/bloc/auth_event.dart';
import '../core/constants/app_colors.dart';
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
          return Scaffold(
            backgroundColor: AppColors.background,
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
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Teams',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
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
    switch (_currentIndex) {
      case 0: // Map page
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create task page
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          child: const Icon(Icons.add),
        );
      case 1: // Tasks page
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create task page
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          child: const Icon(Icons.add),
        );
      case 2: // Teams page
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create team page
            Navigator.of(context).pushNamed('/create-team');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
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
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 48,
                  color: AppColors.surface,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kapok',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Disaster Relief Coordination',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
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
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
