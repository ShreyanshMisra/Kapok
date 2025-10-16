import 'package:equatable/equatable.dart';

/// Team events
abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

/// Create team request
class CreateTeamRequested extends TeamEvent {
  final String name;
  final String leaderId;
  final String? description;

  const CreateTeamRequested({
    required this.name,
    required this.leaderId,
    this.description,
  });

  @override
  List<Object?> get props => [name, leaderId, description];
}

/// Join team request
class JoinTeamRequested extends TeamEvent {
  final String teamCode;
  final String userId;

  const JoinTeamRequested({
    required this.teamCode,
    required this.userId,
  });

  @override
  List<Object> get props => [teamCode, userId];
}

/// Leave team request
class LeaveTeamRequested extends TeamEvent {
  final String teamId;
  final String userId;

  const LeaveTeamRequested({
    required this.teamId,
    required this.userId,
  });

  @override
  List<Object> get props => [teamId, userId];
}

/// Load user teams
class LoadUserTeams extends TeamEvent {
  final String userId;

  const LoadUserTeams({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Load team by ID
class LoadTeam extends TeamEvent {
  final String teamId;

  const LoadTeam({required this.teamId});

  @override
  List<Object> get props => [teamId];
}

/// Update team request
class UpdateTeamRequested extends TeamEvent {
  final String teamId;
  final String name;
  final String? description;

  const UpdateTeamRequested({
    required this.teamId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [teamId, name, description];
}

/// Close team request
class CloseTeamRequested extends TeamEvent {
  final String teamId;
  final String userId;

  const CloseTeamRequested({
    required this.teamId,
    required this.userId,
  });

  @override
  List<Object> get props => [teamId, userId];
}

/// Remove member request
class RemoveMemberRequested extends TeamEvent {
  final String teamId;
  final String memberId;
  final String leaderId;

  const RemoveMemberRequested({
    required this.teamId,
    required this.memberId,
    required this.leaderId,
  });

  @override
  List<Object> get props => [teamId, memberId, leaderId];
}

/// Load team members
class LoadTeamMembers extends TeamEvent {
  final String teamId;

  const LoadTeamMembers({required this.teamId});

  @override
  List<Object> get props => [teamId];
}
