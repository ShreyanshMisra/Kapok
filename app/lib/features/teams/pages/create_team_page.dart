import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../app/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';
import '../../../data/models/team_model.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Create team page for team leaders
class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verify user role before showing form
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userRole = authState.user.userRole;
      if (userRole != UserRole.teamLeader && userRole != UserRole.admin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Only team leaders and admins can create teams',
              ),
              backgroundColor: AppColors.primary,
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
        title: Text(AppLocalizations.of(context).createTeam),
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
          } else if (state is TeamCreated) {
            // Show success dialog with team code first
            // This prevents AuthBloc navigation from interfering
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _TeamCreatedDialog(
                team: state.team,
                onDismiss: () {
                  // Update AuthBloc after dialog is dismissed to prevent navigation conflicts
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<AuthBloc>().add(
                      ProfileUpdateRequested(
                        user: authState.user.copyWith(
                          teamId: state.team.id,
                          updatedAt: DateTime.now(),
                        ),
                      ),
                    );
                  }
                },
              ),
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
                  AppLocalizations.of(context).createNewTeam,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Team name field
                TextFormField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).teamName,
                    hintText: AppLocalizations.of(context).enterTeamName,
                    prefixIcon: const Icon(Icons.group_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).descriptionOptional,
                    hintText: AppLocalizations.of(
                      context,
                    ).briefDescriptionOfTheTeamsPurpose,
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
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
                            AppLocalizations.of(context).teamLeaderBenefits,
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
                        ).teamLeaderBenefitsDescription,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Create team button
                BlocBuilder<TeamBloc, TeamState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is TeamLoading
                          ? null
                          : _handleCreateTeam,
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
                              AppLocalizations.of(context).createTeam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle create team form submission
  void _handleCreateTeam() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youMustBeLoggedInToCreateTeams,
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
        return;
      }

      final currentUserId = authState.user.id;

      context.read<TeamBloc>().add(
        CreateTeamRequested(
          name: _teamNameController.text.trim(),
          leaderId: currentUserId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    }
  }
}

/// Dialog shown after team creation with team code
class _TeamCreatedDialog extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onDismiss;

  const _TeamCreatedDialog({required this.team, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Team Created Successfully!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Name: ${team.teamName}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          const Text(
            'Team Code:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    team.teamCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: team.teamCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Team code copied!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share this code with your team members',
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to teams page first to show the newly created team
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/teams',
              (route) => route.settings.name == '/home' || route.isFirst,
            );
            // Update AuthBloc AFTER navigation to prevent navigation conflicts
            // Use a small delay to ensure navigation completes first
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                onDismiss?.call();
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
