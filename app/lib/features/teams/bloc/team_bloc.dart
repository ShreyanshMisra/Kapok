import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<RemoveMemberRequested>(_onRemoveMemberRequested);
    on<LoadTeamMembers>(_onLoadTeamMembers);
  }

  /// Handle create team request
  Future<void> _onCreateTeamRequested(
    CreateTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Creating team: ${event.name}');
      
      final team = await _teamRepository.createTeam(
        name: event.name,
        leaderId: event.leaderId,
      );
      
      emit(TeamCreated(team: team));
      Logger.team('Team created successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error creating team', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle join team request
  Future<void> _onJoinTeamRequested(
    JoinTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      emit(const TeamLoading());
      Logger.team('Joining team with code: ${event.teamCode}');
      
      final team = await _teamRepository.joinTeam(
        teamCode: event.teamCode,
        userId: event.userId,
      );
      
      emit(TeamJoined(team: team));
      Logger.team('User joined team successfully: ${team.id}');
    } catch (e) {
      Logger.team('Error joining team', error: e);
      emit(TeamError(message: e.toString()));
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
      emit(const TeamLoading());
      Logger.team('Loading teams for user: ${event.userId}');
      
      final teams = await _teamRepository.getUserTeams(event.userId);
      
      emit(TeamLoaded(teams: teams));
      Logger.team('Loaded ${teams.length} teams for user');
    } catch (e) {
      Logger.team('Error loading user teams', error: e);
      emit(TeamError(message: e.toString()));
    }
  }

  /// Handle load team
  Future<void> _onLoadTeam(
    LoadTeam event,
    Emitter<TeamState> emit,
  ) async {
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
        name: event.name,
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
      emit(const TeamLoading());
      Logger.team('Loading team members: ${event.teamId}');
      
      // TODO: Implement team members loading
      // This would require a method in the repository to get team members
      // For now, emit empty list
      emit(const TeamMembersLoaded(members: []));
      Logger.team('Team members loaded successfully');
    } catch (e) {
      Logger.team('Error loading team members', error: e);
      emit(TeamError(message: e.toString()));
    }
  }
}
