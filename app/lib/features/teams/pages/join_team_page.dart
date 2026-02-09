import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Join team page for entering team codes
class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _teamCodeController = TextEditingController();

  @override
  void dispose() {
    _teamCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verify user role before showing form
    // Team Members and Team Leaders can join teams
    // Admins cannot join teams (they have access to all teams)
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.userRole == UserRole.admin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Admins have access to all teams'),
              backgroundColor: AppColors.info,
            ),
          );
          Navigator.of(context).pop();
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).joinTeam),
        centerTitle: true,
        elevation: 0,
        actions: const [KapokLogo()],
      ),
      body: BlocListener<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is TeamJoined) {
            // Update AuthBloc with new teamId (silently, without triggering navigation)
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              // Update user profile with new teamId
              final updatedUser = authState.user.copyWith(
                teamId: state.team.id,
                updatedAt: DateTime.now(),
              );

              // Update AuthBloc state directly without triggering navigation
              context.read<AuthBloc>().add(
                ProfileUpdateRequested(user: updatedUser),
              );
            }

            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations.successfullyJoinedTeam.replaceAll(
                    '{teamName}',
                    state.team.teamName,
                  ),
                ),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 3),
              ),
            );

            // Navigate to teams page instead of just popping
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.teams,
              (route) => route.settings.name == AppRouter.home || route.isFirst,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(Icons.group_add, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),

                Text(
                  AppLocalizations.of(context).joinATeam,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(
                    context,
                  ).enterTheTeamCodeProvidedByYourTeamLeader,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Team code field
                TextFormField(
                  controller: _teamCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).teamCode,
                    hintText: AppLocalizations.of(
                      context,
                    ).enter6CharacterTeamCode,
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterATeamCode;
                    }
                    if (value.length != 6) {
                      return AppLocalizations.of(
                        context,
                      ).teamCodeMustBe6Characters;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Auto-format to uppercase
                    if (value != value.toUpperCase()) {
                      _teamCodeController.value = _teamCodeController.value
                          .copyWith(
                            text: value.toUpperCase(),
                            selection: TextSelection.collapsed(
                              offset: value.length,
                            ),
                          );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).howToGetATeamCode,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).howToGetATeamCodeDescription,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Join team button
                BlocBuilder<TeamBloc, TeamState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is TeamLoading ? null : _handleJoinTeam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is TeamLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).joinTeam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle join team form submission
  void _handleJoinTeam() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youMustBeLoggedInToJoinTeams,
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
        return;
      }

      final currentUserId = authState.user.id;

      context.read<TeamBloc>().add(
        JoinTeamRequested(
          teamCode: _teamCodeController.text.trim().toUpperCase(),
          userId: currentUserId,
        ),
      );
    }
  }
}
