import 'package:equatable/equatable.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/user_model.dart';

/// Team states
abstract class TeamState extends Equatable {
  final List<TeamModel> teams;
  final List<UserModel> members;

  const TeamState({
    this.teams = const [],
    this.members = const [],
  });

  @override
  List<Object?> get props => [teams, members];
}

/// Initial state
class TeamInitial extends TeamState {
  const TeamInitial({super.teams, super.members});
}

/// Loading state
class TeamLoading extends TeamState {
  const TeamLoading({super.teams, super.members});
}

/// Teams loaded state
class TeamLoaded extends TeamState {
  const TeamLoaded({required super.teams, super.members});

  @override
  List<Object> get props => [teams, members];
}

/// Team created state
class TeamCreated extends TeamState {
  final TeamModel team;

  const TeamCreated({
    required this.team,
    super.teams,
    super.members,
  });

  @override
  List<Object?> get props => [team, teams, members];
}

/// Team joined state
class TeamJoined extends TeamState {
  final TeamModel team;

  const TeamJoined({
    required this.team,
    super.teams,
    super.members,
  });

  @override
  List<Object?> get props => [team, teams, members];
}

/// Team updated state
class TeamUpdated extends TeamState {
  final TeamModel team;

  const TeamUpdated({
    required this.team,
    super.teams,
    super.members,
  });

  @override
  List<Object?> get props => [team, teams, members];
}

/// Team members loaded state
class TeamMembersLoaded extends TeamState {
  const TeamMembersLoaded({
    required super.teams,
    required super.members,
  });

  @override
  List<Object> get props => [teams, members];
}

/// Team deleted state
class TeamDeleted extends TeamState {
  final String teamId;

  const TeamDeleted({
    required this.teamId,
    super.teams,
    super.members,
  });

  @override
  List<Object?> get props => [teamId, teams, members];
}

/// Error state
class TeamError extends TeamState {
  final String message;

  const TeamError({
    required this.message,
    super.teams,
    super.members,
  });

  @override
  List<Object?> get props => [message, teams, members];
}
