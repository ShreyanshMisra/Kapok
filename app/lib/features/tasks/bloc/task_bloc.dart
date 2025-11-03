import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

/// Task BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TaskInitial()) {
    on<CreateTaskRequested>(_onCreateTaskRequested);
    on<LoadTasksRequested>(_onLoadTasksRequested);
    on<LoadTasksByTeamRequested>(_onLoadTasksByTeamRequested);
    on<LoadTasksByUserRequested>(_onLoadTasksByUserRequested);
    on<UpdateTaskRequested>(_onUpdateTaskRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
    on<MarkTaskCompletedRequested>(_onMarkTaskCompletedRequested);
    on<AssignTaskRequested>(_onAssignTaskRequested);
  }

  /// Handle create task request
  Future<void> _onCreateTaskRequested(
    CreateTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Creating task: ${event.taskName}');
      
      final now = DateTime.now();
      final taskId = '${event.teamId}_${now.millisecondsSinceEpoch}';
      
      final task = TaskModel(
        id: taskId,
        taskName: event.taskName,
        taskSeverity: event.taskSeverity,
        taskDescription: event.taskDescription,
        taskCompleted: false,
        assignedTo: event.assignedTo,
        teamName: event.teamName,
        teamId: event.teamId,
        latitude: event.latitude,
        longitude: event.longitude,
        createdAt: now,
        updatedAt: now,
        createdBy: event.assignedTo,
      );
      
      final createdTask = await _taskRepository.createTask(task);
      
      emit(TaskCreated(task: createdTask));
      Logger.task('Task created successfully');
    } catch (e) {
      Logger.task('Error creating task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle load tasks request
  Future<void> _onLoadTasksRequested(
    LoadTasksRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Loading all tasks');
      
      final tasks = await _taskRepository.getTasks();
      
      emit(TasksLoaded(tasks: tasks));
      Logger.task('Loaded ${tasks.length} tasks');
    } catch (e) {
      Logger.task('Error loading tasks', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle load tasks by team request
  Future<void> _onLoadTasksByTeamRequested(
    LoadTasksByTeamRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Loading tasks for team: ${event.teamId}');
      
      final tasks = await _taskRepository.getTasksByTeam(event.teamId);
      
      emit(TasksLoaded(tasks: tasks));
      Logger.task('Loaded ${tasks.length} tasks for team');
    } catch (e) {
      Logger.task('Error loading team tasks', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle load tasks by user request
  Future<void> _onLoadTasksByUserRequested(
    LoadTasksByUserRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Loading tasks for user: ${event.userId}');
      
      final tasks = await _taskRepository.getTasksByUser(event.userId);
      
      emit(TasksLoaded(tasks: tasks));
      Logger.task('Loaded ${tasks.length} tasks for user');
    } catch (e) {
      Logger.task('Error loading user tasks', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle update task request
  Future<void> _onUpdateTaskRequested(
    UpdateTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Updating task: ${event.taskId}');
      
      // TODO: Get current task and update it
      // final currentTask = await _taskRepository.getTask(event.taskId);
      // final updatedTask = currentTask.copyWith(...);
      // final task = await _taskRepository.updateTask(updatedTask);
      
      // emit(TaskUpdated(task: task));
      Logger.task('Task updated successfully');
    } catch (e) {
      Logger.task('Error updating task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle delete task request
  Future<void> _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Deleting task: ${event.taskId}');
      
      await _taskRepository.deleteTask(event.taskId);
      
      emit(TaskDeleted(taskId: event.taskId));
      Logger.task('Task deleted successfully');
    } catch (e) {
      Logger.task('Error deleting task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle mark task completed request
  Future<void> _onMarkTaskCompletedRequested(
    MarkTaskCompletedRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Marking task as completed: ${event.taskId}');
      
      final task = await _taskRepository.markTaskCompleted(
        event.taskId,
        event.completed,
      );
      
      emit(TaskUpdated(task: task));
      Logger.task('Task completion status updated');
    } catch (e) {
      Logger.task('Error marking task as completed', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle assign task request
  Future<void> _onAssignTaskRequested(
    AssignTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Assigning task: ${event.taskId} to user: ${event.userId}');
      
      final task = await _taskRepository.assignTask(
        event.taskId,
        event.userId,
      );
      
      emit(TaskUpdated(task: task));
      Logger.task('Task assigned successfully');
    } catch (e) {
      Logger.task('Error assigning task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }
}
