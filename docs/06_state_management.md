# State Management

## Overview

The Kapok application uses the **BLoC (Business Logic Component)** pattern for state management, providing a predictable and testable approach to managing application state. This document covers the BLoC pattern implementation, state management strategies, and best practices.

## BLoC Pattern Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    UI       │ │    UI       │ │    UI       │          │
│  │  Widgets    │ │  Widgets    │ │  Widgets    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
│         │               │               │                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   BLoC      │ │   BLoC      │ │   BLoC      │          │
│  │  (Events)   │ │  (Events)   │ │  (Events)   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
│         │               │               │                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   BLoC      │ │   BLoC      │ │   BLoC      │          │
│  │  (States)   │ │  (States)   │ │  (States)   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Repository  │ │ Repository  │ │ Repository  │          │
│  │   Layer     │ │   Layer     │ │   Layer     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### BLoC Lifecycle

1. **Event Dispatch**: UI dispatches events to BLoC
2. **Event Processing**: BLoC processes business logic
3. **State Emission**: BLoC emits new states
4. **UI Rebuild**: UI rebuilds based on new state

## BLoC Implementation

### Basic BLoC Structure

```dart
// Event classes
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class CreateTask extends TaskEvent {
  final TaskModel task;
  
  const CreateTask(this.task);
  
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  
  const UpdateTask(this.task);
  
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  
  const DeleteTask(this.taskId);
  
  @override
  List<Object?> get props => [taskId];
}

// State classes
abstract class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  
  const TaskLoaded({required this.tasks});
  
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  
  const TaskError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC implementation
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  
  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }
  
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    
    try {
      final tasks = await _taskRepository.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
  
  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final createdTask = await _taskRepository.createTask(event.task);
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        emit(TaskLoaded(tasks: [...currentTasks, createdTask]));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = await _taskRepository.updateTask(event.task);
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final updatedTasks = currentTasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();
        
        emit(TaskLoaded(tasks: updatedTasks));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
  
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        final filteredTasks = currentTasks.where((task) => task.id != event.taskId).toList();
        
        emit(TaskLoaded(tasks: filteredTasks));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
```

## Feature-Specific BLoCs

### Authentication BLoC

```dart
// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String accountType;
  final String role;
  
  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.accountType,
    required this.role,
  });
  
  @override
  List<Object?> get props => [email, password, name, accountType, role];
}

// Auth States
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSignupRequested>(_onSignupRequested);
  }
  
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        accountType: event.accountType,
        role: event.role,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

### Team Management BLoC

```dart
// Team Events
abstract class TeamEvent extends Equatable {
  const TeamEvent();
}

class LoadTeams extends TeamEvent {
  const LoadTeams();
}

class CreateTeam extends TeamEvent {
  final String name;
  final String leaderId;
  
  const CreateTeam({
    required this.name,
    required this.leaderId,
  });
  
  @override
  List<Object?> get props => [name, leaderId];
}

class JoinTeam extends TeamEvent {
  final String teamCode;
  final String userId;
  
  const JoinTeam({
    required this.teamCode,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [teamCode, userId];
}

class LeaveTeam extends TeamEvent {
  final String teamId;
  final String userId;
  
  const LeaveTeam({
    required this.teamId,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [teamId, userId];
}

// Team States
abstract class TeamState extends Equatable {
  const TeamState();
}

class TeamInitial extends TeamState {
  const TeamInitial();
}

class TeamLoading extends TeamState {
  const TeamLoading();
}

class TeamLoaded extends TeamState {
  final List<TeamModel> teams;
  
  const TeamLoaded({required this.teams});
  
  @override
  List<Object?> get props => [teams];
}

class TeamError extends TeamState {
  final String message;
  
  const TeamError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Team BLoC
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRepository _teamRepository;
  
  TeamBloc({required TeamRepository teamRepository})
      : _teamRepository = teamRepository,
        super(const TeamInitial()) {
    on<LoadTeams>(_onLoadTeams);
    on<CreateTeam>(_onCreateTeam);
    on<JoinTeam>(_onJoinTeam);
    on<LeaveTeam>(_onLeaveTeam);
  }
  
  Future<void> _onLoadTeams(LoadTeams event, Emitter<TeamState> emit) async {
    emit(const TeamLoading());
    
    try {
      final teams = await _teamRepository.getTeams();
      emit(TeamLoaded(teams: teams));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }
  
  Future<void> _onCreateTeam(CreateTeam event, Emitter<TeamState> emit) async {
    try {
      final team = await _teamRepository.createTeam(
        name: event.name,
        leaderId: event.leaderId,
      );
      
      if (state is TeamLoaded) {
        final currentTeams = (state as TeamLoaded).teams;
        emit(TeamLoaded(teams: [...currentTeams, team]));
      }
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }
  
  Future<void> _onJoinTeam(JoinTeam event, Emitter<TeamState> emit) async {
    try {
      final team = await _teamRepository.joinTeam(
        teamCode: event.teamCode,
        userId: event.userId,
      );
      
      if (state is TeamLoaded) {
        final currentTeams = (state as TeamLoaded).teams;
        emit(TeamLoaded(teams: [...currentTeams, team]));
      }
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }
  
  Future<void> _onLeaveTeam(LeaveTeam event, Emitter<TeamState> emit) async {
    try {
      await _teamRepository.leaveTeam(
        teamId: event.teamId,
        userId: event.userId,
      );
      
      if (state is TeamLoaded) {
        final currentTeams = (state as TeamLoaded).teams;
        final filteredTeams = currentTeams.where((team) => team.id != event.teamId).toList();
        
        emit(TeamLoaded(teams: filteredTeams));
      }
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }
}
```

## UI Integration

### BLoC Provider Setup

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => sl<TaskBloc>(),
        ),
        BlocProvider<TeamBloc>(
          create: (context) => sl<TeamBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Kapok',
        home: const HomePage(),
      ),
    );
  }
}
```

### BLoC Consumer Usage

```dart
class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskCard(task: task);
              },
            );
          } else if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(const LoadTasks());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(child: Text('No tasks available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTaskPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### BLoC Builder Usage

```dart
class TaskCard extends StatelessWidget {
  final TaskModel task;
  
  const TaskCard({Key? key, required this.task}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.taskName),
        subtitle: Text(task.taskDescription),
        trailing: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return Checkbox(
              value: task.taskCompleted,
              onChanged: (value) {
                if (value != null) {
                  final updatedTask = task.copyWith(taskCompleted: value);
                  context.read<TaskBloc>().add(UpdateTask(updatedTask));
                }
              },
            );
          },
        ),
      ),
    );
  }
}
```

## Advanced BLoC Patterns

### Multi-BLoC Communication

```dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final StreamSubscription<AuthState> _authSubscription;
  
  TaskBloc({
    required TaskRepository taskRepository,
    required AuthBloc authBloc,
  }) : _taskRepository = taskRepository,
        _authSubscription = authBloc.stream.listen((authState) {
          if (authState is AuthAuthenticated) {
            // Load tasks when user is authenticated
            add(const LoadTasks());
          }
        }),
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
  }
  
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
```

### BLoC-to-BLoC Communication

```dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final TeamBloc _teamBloc;
  
  TaskBloc({
    required TaskRepository taskRepository,
    required TeamBloc teamBloc,
  }) : _taskRepository = taskRepository,
        _teamBloc = teamBloc,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
  }
  
  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final createdTask = await _taskRepository.createTask(event.task);
      
      // Notify TeamBloc about new task
      _teamBloc.add(TeamTaskCreated(createdTask));
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        emit(TaskLoaded(tasks: [...currentTasks, createdTask]));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
```

### Stream-based BLoC

```dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  
  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<StartTasksStream>(_onStartTasksStream);
    on<StopTasksStream>(_onStopTasksStream);
  }
  
  Future<void> _onStartTasksStream(StartTasksStream event, Emitter<TaskState> emit) async {
    _tasksSubscription = _taskRepository.getTasksStream().listen(
      (tasks) {
        emit(TaskLoaded(tasks: tasks));
      },
      onError: (error) {
        emit(TaskError(message: error.toString()));
      },
    );
  }
  
  Future<void> _onStopTasksStream(StopTasksStream event, Emitter<TaskState> emit) async {
    await _tasksSubscription?.cancel();
    _tasksSubscription = null;
  }
  
  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
```

## Testing BLoCs

### Unit Tests

```dart
void main() {
  group('TaskBloc', () {
    late TaskBloc taskBloc;
    late MockTaskRepository mockTaskRepository;
    
    setUp(() {
      mockTaskRepository = MockTaskRepository();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
    });
    
    tearDown(() {
      taskBloc.close();
    });
    
    test('initial state is TaskInitial', () {
      expect(taskBloc.state, const TaskInitial());
    });
    
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when LoadTasks is added',
      build: () {
        when(() => mockTaskRepository.getTasks())
            .thenAnswer((_) async => [testTask]);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        TaskLoaded(tasks: [testTask]),
      ],
    );
    
    blocTest<TaskBloc, TaskState>(
      'emits [TaskError] when LoadTasks fails',
      build: () {
        when(() => mockTaskRepository.getTasks())
            .thenThrow(Exception('Failed to load tasks'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        const TaskError(message: 'Exception: Failed to load tasks'),
      ],
    );
  });
}
```

### Mock Repository

```dart
class MockTaskRepository extends Mock implements TaskRepository {}
```

## Best Practices

### 1. Event Design

- **Single Responsibility**: Each event should represent one action
- **Immutable**: Events should be immutable
- **Equatable**: Implement Equatable for proper comparison
- **Descriptive Names**: Use clear, descriptive event names

### 2. State Design

- **Immutable**: States should be immutable
- **Equatable**: Implement Equatable for proper comparison
- **Minimal**: Keep states minimal and focused
- **Clear Transitions**: Define clear state transitions

### 3. BLoC Implementation

- **Single Responsibility**: Each BLoC should handle one feature
- **Error Handling**: Always handle errors gracefully
- **Resource Management**: Properly dispose of resources
- **Testing**: Write comprehensive tests

### 4. Performance

- **Lazy Loading**: Load data only when needed
- **Caching**: Cache frequently accessed data
- **Debouncing**: Debounce user input events
- **Stream Management**: Properly manage stream subscriptions

### 5. Code Organization

- **Feature-based**: Organize BLoCs by features
- **Consistent Naming**: Use consistent naming conventions
- **Documentation**: Document complex business logic
- **Separation of Concerns**: Keep UI and business logic separate