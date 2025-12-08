import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/team_repository.dart';
import 'team_event.dart';
import 'team_state.dart';

/// Team BLoC
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRepository _teamRepository;

  TeamBloc({required TeamRepository teamRepository})
    : _teamRepository = teamRepository,
      super(const TeamInitial()) {
    on<CreateTeamRequested>(_onCreateTeamRequested);
    on<JoinTeamRequested>(_onJoinTeamRequested);
    on<LeaveTeamRequested>(_onLeaveTeamRequested);
    on<LoadUserTeams>(_onLoadUserTeams);
    on<LoadTeam>(_onLoadTeam);
    on<UpdateTeamRequested>(_onUpdateTeamRequested);
    on<CloseTeamRequested>(_onCloseTeamRequested);
    on<DeleteTeamRequested>(_onDeleteTeamRequested);
    on<RemoveMemberRequested>(_onRemoveMemberRequested);
    on<LoadTeamMembers>(_onLoadTeamMembers);
    on<TeamReset>(_onTeamReset);
  }

  /// Handle create team request
  Future<void> _onCreateTeamRequested(
    CreateTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(TeamLoading(teams: state.teams, members: state.members));
      Logger.team('Creating team: ${event.name}');

      final team = await _teamRepository.createTeam(
        teamName: event.name,
        leaderId: event.leaderId,
        description: event.description,
      );

      emit(TeamCreated(team: team, teams: state.teams, members: state.members));
      Logger.team('Team created successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error creating team', error: e);
      // Extract user-friendly error message
      String errorMessage;
      if (e is TeamException) {
        errorMessage = e.message;
      } else if (e is DatabaseException) {
        errorMessage = e.message;
      } else if (e is CacheException) {
        errorMessage = 'Failed to save team locally: ${e.message}';
      } else {
        errorMessage = e.toString();
        // Try to extract more specific error
        final errorStr = errorMessage.toLowerCase();
        if (errorStr.contains('permission') || errorStr.contains('denied')) {
          errorMessage =
              'Permission denied. Please check your account permissions.';
        } else if (errorStr.contains('network') ||
            errorStr.contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        } else if (errorStr.contains('firestore')) {
          errorMessage = 'Database error. Please try again later.';
        } else {
          errorMessage = 'Failed to create team: ${e.toString()}';
        }
      }
      Logger.team('Team creation error message: $errorMessage');
      emit(
        TeamError(
          message: errorMessage,
          teams: state.teams,
          members: state.members,
        ),
      );
    }
  }

  /// Handle join team request
  Future<void> _onJoinTeamRequested(
    JoinTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(TeamLoading(teams: state.teams, members: state.members));
      Logger.team('Joining team with code: ${event.teamCode}');

      final team = await _teamRepository.joinTeam(
        teamCode: event.teamCode,
        userId: event.userId,
      );

      emit(TeamJoined(team: team, teams: state.teams, members: state.members));
      Logger.team('User joined team successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error joining team', error: e);
      Logger.team('Error type: ${e.runtimeType}');

      // Extract user-friendly error message
      String errorMessage;
      if (e is TeamException) {
        errorMessage = e.message;
      } else if (e is DatabaseException) {
        errorMessage = e.message;
      } else if (e is CacheException) {
        errorMessage = 'Failed to save team locally: ${e.message}';
      } else {
        errorMessage = e.toString();
        // Try to extract more specific error
        final errorStr = errorMessage.toLowerCase();
        if (errorStr.contains('invalid team code') ||
            errorStr.contains('not found')) {
          errorMessage =
              'Invalid team code. Please check the code and try again.';
        } else if (errorStr.contains('already a member')) {
          errorMessage = 'You are already a member of this team.';
        } else if (errorStr.contains('team is full')) {
          errorMessage = 'This team is full (maximum 50 members).';
        } else if (errorStr.contains('permission') ||
            errorStr.contains('denied')) {
          errorMessage =
              'Permission denied. Please check your account permissions.';
        } else if (errorStr.contains('network') ||
            errorStr.contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        } else if (errorStr.contains('firestore') ||
            errorStr.contains('database')) {
          errorMessage = 'Database error. Please try again later.';
        } else {
          // Try to extract the actual error message from nested exceptions
          if (errorMessage.contains('Error:')) {
            final parts = errorMessage.split('Error:');
            if (parts.length > 1) {
              errorMessage = parts.last.trim();
            }
          }
          errorMessage = 'Failed to join team: $errorMessage';
        }
      }
      Logger.team('Team join error message: $errorMessage');
      emit(
        TeamError(
          message: errorMessage,
          teams: state.teams,
          members: state.members,
        ),
      );
    }
  }

  /// Handle leave team request
  Future<void> _onLeaveTeamRequested(
    LeaveTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Leaving team: ${event.teamId}');

      await _teamRepository.leaveTeam(
        teamId: event.teamId,
        userId: event.userId,
      );

      // Reload user teams after leaving
      add(LoadUserTeams(userId: event.userId));
      Logger.team('User left team successfully');
    } catch (e) {
      Logger.team('Error leaving team', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle load user teams
  Future<void> _onLoadUserTeams(
    LoadUserTeams event,
    Emitter<TeamState> emit,
  ) async {
    try {
      // Preserve current teams and members
      emit(TeamLoading(teams: state.teams, members: state.members));
      Logger.team('Loading teams for user: ${event.userId}');

      final teams = await _teamRepository.getUserTeams(event.userId);

      emit(TeamLoaded(teams: teams, members: state.members));
      Logger.team('Loaded ${teams.length} teams for user');
    } catch (e) {
      Logger.team('Error loading user teams', error: e);
      emit(
        TeamError(
          message: e.toString(),
          teams: state.teams,
          members: state.members,
        ),
      );
    }
  }

  /// Handle load team
  Future<void> _onLoadTeam(LoadTeam event, Emitter<TeamState> emit) async {
    try {
      emit(const TeamLoading());
      Logger.team('Loading team: ${event.teamId}');

      final team = await _teamRepository.getTeam(event.teamId);

      emit(TeamLoaded(teams: [team]));
      Logger.team('Team loaded successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error loading team', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle update team request
  Future<void> _onUpdateTeamRequested(
    UpdateTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Updating team: ${event.teamId}');

      // Get current team
      final currentTeam = await _teamRepository.getTeam(event.teamId);

      // Create updated team
      final updatedTeam = currentTeam.copyWith(
        teamName: event.name,
        description: event.description,
      );

      final team = await _teamRepository.updateTeam(updatedTeam);

      emit(TeamUpdated(team: team));
      Logger.team('Team updated successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error updating team', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle close team request
  Future<void> _onCloseTeamRequested(
    CloseTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Closing team: ${event.teamId}');

      await _teamRepository.closeTeam(
        teamId: event.teamId,
        userId: event.userId,
      );

      // Reload user teams after closing
      add(LoadUserTeams(userId: event.userId));
      Logger.team('Team closed successfully');
    } catch (e) {
      Logger.team('Error closing team', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle delete team request
  Future<void> _onDeleteTeamRequested(
    DeleteTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(TeamLoading(teams: state.teams, members: state.members));
      Logger.team('Deleting team: ${event.teamId}');

      await _teamRepository.deleteTeam(
        teamId: event.teamId,
        userId: event.userId,
      );

      // Remove deleted team from current teams list
      final updatedTeams = state.teams
          .where((t) => t.id != event.teamId)
          .toList();

      emit(
        TeamDeleted(
          teamId: event.teamId,
          teams: updatedTeams,
          members: state.members,
        ),
      );

      // Reload user teams after deletion to ensure consistency
      add(LoadUserTeams(userId: event.userId));
      Logger.team('Team deleted successfully');
    } catch (e) {
      Logger.team('Error deleting team', error: e);
      emit(
        TeamError(
          message: e.toString(),
          teams: state.teams,
          members: state.members,
        ),
      );
    }
  }

  /// Handle remove member request
  Future<void> _onRemoveMemberRequested(
    RemoveMemberRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Removing member from team: ${event.teamId}');

      await _teamRepository.removeMember(
        teamId: event.teamId,
        memberId: event.memberId,
        leaderId: event.leaderId,
      );

      // Reload team after removing member
      add(LoadTeam(teamId: event.teamId));
      Logger.team('Member removed successfully');
    } catch (e) {
      Logger.team('Error removing member', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle load team members
  Future<void> _onLoadTeamMembers(
    LoadTeamMembers event,
    Emitter<TeamState> emit,
  ) async {
    try {
      // Preserve current teams list
      emit(TeamLoading(teams: state.teams, members: state.members));
      Logger.team('Loading team members: ${event.teamId}');

      final members = await _teamRepository.getTeamMembers(event.teamId);

      emit(TeamMembersLoaded(teams: state.teams, members: members));
      Logger.team(
        'Team members loaded successfully: ${members.length} members',
      );
    } catch (e) {
      Logger.team('Error loading team members', error: e);
      emit(
        TeamError(
          message: e.toString(),
          teams: state.teams,
          members: state.members,
        ),
      );
    }
  }

  /// Handle team reset (on logout)
  Future<void> _onTeamReset(TeamReset event, Emitter<TeamState> emit) async {
    Logger.team('Resetting team state');
    emit(const TeamInitial());
  }
}
