import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/logger.dart';
import '../../../data/sources/firebase_source.dart';
import '../../../data/sources/hive_source.dart';
import '../../../injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../teams/pages/create_team_page.dart';
import '../../teams/pages/join_team_page.dart';
import '../../../app/home_page.dart';
import '../../../core/localization/app_localizations.dart';

/// Role selection page for user onboarding
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header
                Text(
                  AppLocalizations.of(context).chooseYourRole,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).selectYourRoleToGetStarted,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Role cards
                _RoleCard(
                  role: UserRole.teamLeader,
                  icon: Icons.groups,
                  title: AppLocalizations.of(context).teamLeader,
                  subtitle: AppLocalizations.of(context).teamLeaderRoleDescription,
                  onTap: () => _handleRoleSelection(context, UserRole.teamLeader),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: UserRole.teamMember,
                  icon: Icons.person_add,
                  title: AppLocalizations.of(context).teamMember,
                  subtitle: AppLocalizations.of(context).teamMemberRoleDescription,
                  onTap: () => _handleRoleSelection(context, UserRole.teamMember),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: UserRole.admin,
                  icon: Icons.admin_panel_settings,
                  title: AppLocalizations.of(context).admin,
                  subtitle: AppLocalizations.of(context).adminRoleDescription,
                  onTap: () => _handleRoleSelection(context, UserRole.admin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRoleSelection(
    BuildContext context,
    UserRole selectedRole,
  ) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mustBeLoggedInToSelectRole),
        ),
      );
      return;
    }

    final currentUser = authState.user;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noSignedInUser),
        ),
      );
      return;
    }

    try {
      // Update user with selected role
      final updatedUser = currentUser.copyWith(
        userRole: selectedRole,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore (create if doesn't exist, update if exists)
      final firebaseSource = sl<FirebaseSource>();
      try {
        // Try to update first (if user exists)
        await firebaseSource.updateUser(updatedUser);
        Logger.auth('User updated in Firestore');
      } catch (e) {
        // If update fails (user doesn't exist), create the user
        if (e.toString().contains('not found') || 
            e.toString().contains('User not found') ||
            e.toString().contains('No document to update')) {
          Logger.auth('User not found in Firestore, creating new user document');
          await firebaseSource.createUser(updatedUser);
          Logger.auth('User created in Firestore');
        } else {
          Logger.auth('Error saving user to Firestore', error: e);
          rethrow;
        }
      }

      // Save to Hive
      final hiveSource = sl<HiveSource>();
      await hiveSource.saveUser(updatedUser);

      if (!context.mounted) return;

      // Update AuthBloc state
      context.read<AuthBloc>().add(ProfileUpdateRequested(user: updatedUser));

      // Navigate based on role
      if (selectedRole == UserRole.teamLeader) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreateTeamPage()),
        );
      } else if (selectedRole == UserRole.teamMember) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const JoinTeamPage()),
        );
      } else if (selectedRole == UserRole.admin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      Logger.auth('Error selecting role', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectRoleFailed),
        ),
      );
    }
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

