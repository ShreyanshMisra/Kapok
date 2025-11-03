import 'package:equatable/equatable.dart';

/// Task events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Create task request
class CreateTaskRequested extends TaskEvent {
  final String taskName;
  final int taskSeverity;
  final String taskDescription;
  final bool taskCompleted;
  final String assignedTo;
  final String teamName;
  final String teamId;
  final double latitude;
  final double longitude;
  final String createdBy;

  const CreateTaskRequested({
    required this.taskName,
    required this.taskSeverity,
    required this.taskDescription,
    this.taskCompleted = false,
    required this.assignedTo,
    required this.teamName,
    required this.teamId,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
  });

  @override
  List<Object> get props => [
    taskName,
    taskSeverity,
    taskDescription,
    taskCompleted,
    assignedTo,
    teamName,
    teamId,
    latitude,
    longitude,
    createdBy,
  ];
}

/// Load tasks request
class LoadTasksRequested extends TaskEvent {
  const LoadTasksRequested();
}

/// Load tasks by team request
class LoadTasksByTeamRequested extends TaskEvent {
  final String teamId;

  const LoadTasksByTeamRequested({required this.teamId});

  @override
  List<Object> get props => [teamId];
}

/// Load tasks by user request
class LoadTasksByUserRequested extends TaskEvent {
  final String userId;

  const LoadTasksByUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Update task request
class UpdateTaskRequested extends TaskEvent {
  final String taskId;
  final String taskName;
  final int taskSeverity;
  final String taskDescription;
  final bool taskCompleted;
  final String assignedTo;

  const UpdateTaskRequested({
    required this.taskId,
    required this.taskName,
    required this.taskSeverity,
    required this.taskDescription,
    required this.taskCompleted,
    required this.assignedTo,
  });

  @override
  List<Object> get props => [
    taskId,
    taskName,
    taskSeverity,
    taskDescription,
    taskCompleted,
    assignedTo,
  ];
}

/// Delete task request
class DeleteTaskRequested extends TaskEvent {
  final String taskId;

  const DeleteTaskRequested({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

/// Mark task completed request
class MarkTaskCompletedRequested extends TaskEvent {
  final String taskId;
  final bool completed;

  const MarkTaskCompletedRequested({
    required this.taskId,
    required this.completed,
  });

  @override
  List<Object> get props => [taskId, completed];
}

/// Assign task request
class AssignTaskRequested extends TaskEvent {
  final String taskId;
  final String userId;

  const AssignTaskRequested({
    required this.taskId,
    required this.userId,
  });

  @override
  List<Object> get props => [taskId, userId];
}
