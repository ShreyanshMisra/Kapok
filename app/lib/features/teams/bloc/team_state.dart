import 'package:equatable/equatable.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/user_model.dart';

/// Team states
abstract class TeamState extends Equatable {
  const TeamState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TeamInitial extends TeamState {
  const TeamInitial();
}

/// Loading state
class TeamLoading extends TeamState {
  const TeamLoading();
}

/// Teams loaded state
class TeamLoaded extends TeamState {
  final List<TeamModel> teams;

  const TeamLoaded({required this.teams});

  @override
  List<Object> get props => [teams];
}

/// Team created state
class TeamCreated extends TeamState {
  final TeamModel team;

  const TeamCreated({required this.team});

  @override
  List<Object> get props => [team];
}

/// Team joined state
class TeamJoined extends TeamState {
  final TeamModel team;

  const TeamJoined({required this.team});

  @override
  List<Object> get props => [team];
}

/// Team updated state
class TeamUpdated extends TeamState {
  final TeamModel team;

  const TeamUpdated({required this.team});

  @override
  List<Object> get props => [team];
}

/// Team members loaded state
class TeamMembersLoaded extends TeamState {
  final List<UserModel> members;

  const TeamMembersLoaded({required this.members});

  @override
  List<Object> get props => [members];
}

/// Error state
class TeamError extends TeamState {
  final String message;

  const TeamError({required this.message});

  @override
  List<Object> get props => [message];
}
