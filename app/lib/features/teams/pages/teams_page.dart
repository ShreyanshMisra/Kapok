import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/enums/user_role.dart';
import '../../../data/models/team_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';
import 'create_team_page.dart';
import 'join_team_page.dart';
import 'team_detail_page.dart';

/// Teams page showing user's teams
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTeams();
        _hasInitialized = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload teams when page becomes visible if state has no teams
    if (_hasInitialized && mounted) {
      final teamState = context.read<TeamBloc>().state;
      // Only reload if state has no teams (TeamInitial or empty TeamLoaded)
      if (teamState.teams.isEmpty &&
          (teamState is TeamInitial ||
              (teamState is TeamLoaded && teamState.teams.isEmpty))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadTeams();
          }
        });
      }
    }
  }

  /// Load user teams
  void _loadTeams() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeamBloc>().add(LoadUserTeams(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).myTeams),
        elevation: 0,
        actions: [
          // Only show create team button for team leaders and admins
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final userRole = authState.user.userRole;
                if (userRole == UserRole.teamLeader ||
                    userRole == UserRole.admin) {
                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateTeamPage(),
                        ),
                      );
                    },
                    tooltip: AppLocalizations.of(context).createTeam,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          // Join team button for team members (and others who can join)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final userRole = authState.user.userRole;
                // Show join button for team members, or if user doesn't have a team yet
                if (userRole == UserRole.teamMember ||
                    (authState.user.teamId == null &&
                        userRole != UserRole.admin)) {
                  return IconButton(
                    icon: const Icon(Icons.group_add),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const JoinTeamPage(),
                        ),
                      );
                    },
                    tooltip: AppLocalizations.of(context).joinTeam,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<TeamBloc, TeamState>(
        listener: (context, state) {
          // When teams are joined/created, reload the list
          if (state is TeamJoined || state is TeamCreated) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<TeamBloc>().add(
                LoadUserTeams(userId: authState.user.id),
              );
            }
          }
        },
        child: BlocBuilder<TeamBloc, TeamState>(
          builder: (context, state) {
            // Loading state with no teams yet
            if (state is TeamLoading &&
                state.teams.isEmpty &&
                !_hasInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state - show error but still display teams if available
            if (state is TeamError) {
              if (state.teams.isNotEmpty) {
                // Show teams with error banner
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: AppColors.error.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.message,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<TeamBloc>().add(
                              LoadUserTeams(userId: authState.user.id),
                            );
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.teams.length,
                          itemBuilder: (context, index) {
                            final team = state.teams[index];
                            return _buildTeamCard(team);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }

              // No teams, show full error state
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).errorLoadingTeams,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<TeamBloc>().add(
                            LoadUserTeams(userId: authState.user.id),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              );
            }

            // Any state with teams - show them
            if (state.teams.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<TeamBloc>().add(
                      LoadUserTeams(userId: authState.user.id),
                    );
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.teams.length,
                  itemBuilder: (context, index) {
                    final team = state.teams[index];
                    return _buildTeamCard(team);
                  },
                ),
              );
            }

            // Empty state - no teams
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  /// Build empty state when no teams
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).noTeamsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              ).joinAnExistingTeamOrCreateANewOneToGetStarted,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              AppLocalizations.of(context).joinAnExistingTeamOrCreateANewOneToGetStarted,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  final userRole = authState.user.userRole;

                  // Show different buttons based on role
                  if (userRole == UserRole.teamMember) {
                    // Team members can only join teams
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const JoinTeamPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_add),
                      label: Text(AppLocalizations.of(context).joinTeam),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    );
                  } else if (userRole == UserRole.teamLeader ||
                      userRole == UserRole.admin) {
                    // Team leaders and admins can create teams
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateTeamPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context).createTeam),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
                  },
                  icon: const Icon(Icons.group_add),
                  label: Text(AppLocalizations.of(context).joinTeam),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateTeamPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).createTeam),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build team card widget
  Widget _buildTeamCard(TeamModel team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TeamDetailPage(team: team)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.group,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.teamName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${team.memberIds.length} ${team.memberIds.length != 1 ? AppLocalizations.of(context).members : AppLocalizations.of(context).member}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: team.isActive
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  team.isActive
                      ? AppLocalizations.of(context).active
                      : AppLocalizations.of(context).inactive,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: team.isActive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
