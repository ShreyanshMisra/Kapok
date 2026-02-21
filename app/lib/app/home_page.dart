import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:badges/badges.dart' as badges;
import 'package:kapok_app/features/auth/bloc/auth_event.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/task_status.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/sync_status_widget.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/tasks/bloc/task_bloc.dart';
import '../features/tasks/bloc/task_state.dart';
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
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final List<Widget> _pages = [
    const MapPage(),
    const TasksPage(),
    const TeamsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final offline = results.contains(ConnectivityResult.none);
        if (mounted && offline != _isOffline) {
          setState(() => _isOffline = offline);
        }
      },
    );
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                // Offline banner
                if (_isOffline)
                  MaterialBanner(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    content: Row(
                      children: [
                        const Icon(Icons.cloud_off, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).offlineBanner,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange.shade700,
                    actions: const [SizedBox.shrink()],
                  ),
                // Sync status indicator
                const SyncStatusWidget(),
                // Main content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
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
                  icon: const Icon(Icons.map),
                  label: AppLocalizations.of(context).map,
                ),
                BottomNavigationBarItem(
                  icon: BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, taskState) {
                      int pendingCount = 0;
                      if (taskState is TasksLoaded) {
                        pendingCount = taskState.tasks
                            .where((t) =>
                                t.status == TaskStatus.pending ||
                                t.status == TaskStatus.inProgress)
                            .length;
                      }
                      if (pendingCount == 0) {
                        return const Icon(Icons.assignment);
                      }
                      return badges.Badge(
                        badgeContent: Text(
                          pendingCount > 99 ? '99+' : '$pendingCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppColors.primary,
                          padding: EdgeInsets.all(4),
                        ),
                        child: const Icon(Icons.assignment),
                      );
                    },
                  ),
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
      case 0: // Map page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.add),
        );
      case 1: // Tasks page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-task');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.add),
        );
      case 2: // Teams page
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/join-team');
          },
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          child: const Icon(Icons.person_add),
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
