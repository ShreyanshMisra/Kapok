import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/task_category.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
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
    on<LoadTasksForUserTeamsRequested>(_onLoadTasksForUserTeamsRequested);
    on<UpdateTaskRequested>(_onUpdateTaskRequested);
    on<EditTaskRequested>(_onEditTaskRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
    on<MarkTaskCompletedRequested>(_onMarkTaskCompletedRequested);
    on<AssignTaskRequested>(_onAssignTaskRequested);
    on<StatusChangeRequested>(_onStatusChangeRequested);
    on<TaskReset>(_onTaskReset);
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
      final taskId = 'task_${now.millisecondsSinceEpoch}';

      // Convert old event structure to new TaskModel structure
      final priority = _convertSeverityToPriority(event.taskSeverity);
      final status = event.taskCompleted
          ? TaskStatus.completed
          : TaskStatus.pending;
      final geoLocation = GeoPoint(event.latitude, event.longitude);

      final task = TaskModel(
        id: taskId,
        title: event.taskName,
        description: event.taskDescription.isNotEmpty
            ? event.taskDescription
            : null,
        createdBy: event.createdBy,
        assignedTo: event.assignedTo.isEmpty ? null : event.assignedTo,
        teamId: event.teamId,
        geoLocation: geoLocation,
        address: null, // Will be reverse-geocoded if needed
        status: status,
        priority: priority,
        category: TaskCategory.fromString(event.category),
        dueDate: event.dueDate,
        createdAt: now,
        updatedAt: now,
        completedAt: event.taskCompleted ? now : null,
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
      Logger.task(
        'Loading tasks${event.userId != null ? " for user: ${event.userId}" : ""}',
      );

      final tasks = await _taskRepository.getTasks(userId: event.userId);

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

  /// Handle load tasks for user's teams request (permission-aware)
  Future<void> _onLoadTasksForUserTeamsRequested(
    LoadTasksForUserTeamsRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task(
        'Loading tasks for user\'s teams: ${event.teamIds.length} teams${event.userId != null ? " (user: ${event.userId})" : ""}',
      );

      final tasks = await _taskRepository.getTasksForUserTeams(
        event.teamIds,
        userId: event.userId,
      );

      emit(TasksLoaded(tasks: tasks));
      Logger.task('Loaded ${tasks.length} tasks for user\'s teams');
    } catch (e) {
      Logger.task('Error loading tasks for user\'s teams', error: e);
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

      // Get current task and update it
      final currentTask = await _taskRepository.getTask(event.taskId);

      // Convert old event structure to new TaskModel structure
      final priority = _convertSeverityToPriority(event.taskSeverity);
      final status = (event.taskCompleted ? TaskStatus.completed : TaskStatus.pending);

      final updatedTask = currentTask.copyWith(
        title: event.taskName,
        description: event.taskDescription,
        assignedTo: event.assignedTo,
        status: status,
        priority: priority,
        updatedAt: DateTime.now(),
        completedAt: event.taskCompleted == true
            ? DateTime.now()
            : currentTask.completedAt,
      );
      final task = await _taskRepository.updateTask(updatedTask);

      emit(TaskUpdated(task: task));
      Logger.task('Task updated successfully');
    } catch (e) {
      Logger.task('Error updating task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle edit task request (with permission check)
  Future<void> _onEditTaskRequested(
    EditTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Editing task: ${event.taskId} by user: ${event.userId}');

      final task = await _taskRepository.editTask(
        taskId: event.taskId,
        userId: event.userId,
        taskName: event.taskName,
        taskSeverity: event.taskSeverity,
        taskDescription: event.taskDescription,
        taskCompleted: event.taskCompleted,
        assignedTo: event.assignedTo,
        category: event.category,
        dueDate: event.dueDate,
        clearDueDate: event.clearDueDate,
      );

      emit(TaskUpdated(task: task));
      Logger.task('Task edited successfully');
    } catch (e) {
      Logger.task('Error editing task', error: e);
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

      final task = await _taskRepository.assignTask(event.taskId, event.userId);

      emit(TaskUpdated(task: task));
      Logger.task('Task assigned successfully');
    } catch (e) {
      Logger.task('Error assigning task', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Handle status change request with validation and history tracking
  Future<void> _onStatusChangeRequested(
    StatusChangeRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());
      Logger.task('Changing status of task: ${event.taskId} to ${event.newStatus.value}');

      final task = await _taskRepository.changeTaskStatus(
        taskId: event.taskId,
        newStatus: event.newStatus,
        userId: event.userId,
        userRole: event.userRole,
      );

      emit(TaskUpdated(task: task));
      Logger.task('Task status changed successfully');
    } catch (e) {
      Logger.task('Error changing task status', error: e);
      emit(TaskError(message: e.toString()));
    }
  }

  /// Convert old severity int (1-5) to TaskPriority enum
  TaskPriority _convertSeverityToPriority(int severity) {
    if (severity >= 4) {
      return TaskPriority.high;
    } else if (severity >= 3) {
      return TaskPriority.medium;
    } else {
      return TaskPriority.low;
    }
  }

  /// Handle task reset (on logout)
  Future<void> _onTaskReset(TaskReset event, Emitter<TaskState> emit) async {
    Logger.task('Resetting task state');
    emit(const TaskInitial());
  }
}
