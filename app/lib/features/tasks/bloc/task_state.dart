import 'package:equatable/equatable.dart';
import '../../../data/models/task_model.dart';

/// Task states
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Tasks loaded state
class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;

  const TasksLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

/// Task created state
class TaskCreated extends TaskState {
  final TaskModel task;

  const TaskCreated({required this.task});

  @override
  List<Object> get props => [task];
}

/// Task updated state
class TaskUpdated extends TaskState {
  final TaskModel task;

  const TaskUpdated({required this.task});

  @override
  List<Object> get props => [task];
}

/// Task deleted state
class TaskDeleted extends TaskState {
  final String taskId;

  const TaskDeleted({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

/// Error state
class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object> get props => [message];
}
