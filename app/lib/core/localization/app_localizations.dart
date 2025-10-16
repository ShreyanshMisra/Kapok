import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// App localizations delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// App localizations class
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  // App Information
  String get appName => _getString('appName');
  String get appDescription => _getString('appDescription');
  String get appVersion => _getString('appVersion');

  // Authentication
  String get login => _getString('login');
  String get createAccount => _getString('createAccount');
  String get email => _getString('email');
  String get password => _getString('password');
  String get confirmPassword => _getString('confirmPassword');
  String get name => _getString('name');
  String get forgotPassword => _getString('forgotPassword');
  String get signOut => _getString('signOut');

  // Account Types
  String get admin => _getString('admin');
  String get teamLeader => _getString('teamLeader');
  String get teamMember => _getString('teamMember');

  // Roles
  String get medical => _getString('medical');
  String get engineering => _getString('engineering');
  String get carpentry => _getString('carpentry');
  String get plumbing => _getString('plumbing');
  String get construction => _getString('construction');
  String get electrical => _getString('electrical');
  String get supplies => _getString('supplies');
  String get transportation => _getString('transportation');
  String get other => _getString('other');

  // Navigation
  String get home => _getString('home');
  String get map => _getString('map');
  String get tasks => _getString('tasks');
  String get teams => _getString('teams');
  String get profile => _getString('profile');
  String get about => _getString('about');
  String get settings => _getString('settings');

  // Tasks
  String get createTask => _getString('createTask');
  String get editTask => _getString('editTask');
  String get deleteTask => _getString('deleteTask');
  String get taskName => _getString('taskName');
  String get taskDescription => _getString('taskDescription');
  String get taskSeverity => _getString('taskSeverity');
  String get taskCompleted => _getString('taskCompleted');
  String get assignedTo => _getString('assignedTo');
  String get teamName => _getString('teamName');
  String get location => _getString('location');
  String get myTasks => _getString('myTasks');
  String get teamTasks => _getString('teamTasks');
  String get allTasks => _getString('allTasks');

  // Task Severity Levels
  String get severity1 => _getString('severity1');
  String get severity2 => _getString('severity2');
  String get severity3 => _getString('severity3');
  String get severity4 => _getString('severity4');
  String get severity5 => _getString('severity5');

  // Teams
  String get createTeam => _getString('createTeam');
  String get joinTeam => _getString('joinTeam');
  String get teamCode => _getString('teamCode');
  String get generateCode => _getString('generateCode');
  String get teamMembers => _getString('teamMembers');
  String get removeMember => _getString('removeMember');
  String get closeTeam => _getString('closeTeam');

  // Map
  String get mapView => _getString('mapView');
  String get listView => _getString('listView');
  String get tapToCreateTask => _getString('tapToCreateTask');
  String get currentLocation => _getString('currentLocation');
  String get searchLocation => _getString('searchLocation');

  // Profile
  String get editProfile => _getString('editProfile');
  String get changeName => _getString('changeName');
  String get changeRole => _getString('changeRole');
  String get accountType => _getString('accountType');
  String get role => _getString('role');

  // About
  String get aboutKapok => _getString('aboutKapok');
  String get aboutNCTDR => _getString('aboutNCTDR');
  String get nationalCenterForTechnologyAndDisputeResolution => _getString('nationalCenterForTechnologyAndDisputeResolution');
  String get disasterReliefCoordination => _getString('disasterReliefCoordination');

  // Settings
  String get language => _getString('language');
  String get english => _getString('english');
  String get spanish => _getString('spanish');
  String get notifications => _getString('notifications');
  String get offlineMode => _getString('offlineMode');
  String get syncData => _getString('syncData');

  // Status Messages
  String get loading => _getString('loading');
  String get saving => _getString('saving');
  String get syncing => _getString('syncing');
  String get offline => _getString('offline');
  String get online => _getString('online');
  String get error => _getString('error');
  String get success => _getString('success');
  String get warning => _getString('warning');
  String get info => _getString('info');

  // Validation Messages
  String get fieldRequired => _getString('fieldRequired');
  String get emailInvalid => _getString('emailInvalid');
  String get passwordTooShort => _getString('passwordTooShort');
  String get passwordsDoNotMatch => _getString('passwordsDoNotMatch');
  String get nameTooShort => _getString('nameTooShort');
  String get teamCodeInvalid => _getString('teamCodeInvalid');

  // Confirmation Messages
  String get confirmDelete => _getString('confirmDelete');
  String get confirmSignOut => _getString('confirmSignOut');
  String get confirmCloseTeam => _getString('confirmCloseTeam');
  String get confirmRemoveMember => _getString('confirmRemoveMember');

  // Success Messages
  String get taskCreated => _getString('taskCreated');
  String get taskUpdated => _getString('taskUpdated');
  String get taskDeleted => _getString('taskDeleted');
  String get teamCreated => _getString('teamCreated');
  String get teamJoined => _getString('teamJoined');
  String get profileUpdated => _getString('profileUpdated');
  String get dataSynced => _getString('dataSynced');

  // Error Messages
  String get networkError => _getString('networkError');
  String get authError => _getString('authError');
  String get permissionDenied => _getString('permissionDenied');
  String get locationPermissionDenied => _getString('locationPermissionDenied');
  String get teamCodeNotFound => _getString('teamCodeNotFound');
  String get teamAlreadyJoined => _getString('teamAlreadyJoined');
  String get taskNotFound => _getString('taskNotFound');
  String get teamNotFound => _getString('teamNotFound');
  String get userNotFound => _getString('userNotFound');

  /// Gets localized string
  String _getString(String key) {
    final Map<String, Map<String, String>> _localizedValues = {
      'en': {
        // App Information
        'appName': 'Kapok',
        'appDescription': 'Disaster Relief Coordination App',
        'appVersion': '1.0.0',
        
        // Authentication
        'login': 'Login',
        'createAccount': 'Create Account',
        'email': 'Email',
        'password': 'Password',
        'confirmPassword': 'Confirm Password',
        'name': 'Name',
        'forgotPassword': 'Forgot Password?',
        'signOut': 'Sign Out',
        
        // Account Types
        'admin': 'Admin',
        'teamLeader': 'Team Leader',
        'teamMember': 'Team Member',
        
        // Roles
        'medical': 'Medical',
        'engineering': 'Engineering',
        'carpentry': 'Carpentry',
        'plumbing': 'Plumbing',
        'construction': 'Construction',
        'electrical': 'Electrical',
        'supplies': 'Supplies',
        'transportation': 'Transportation',
        'other': 'Other',
        
        // Navigation
        'home': 'Home',
        'map': 'Map',
        'tasks': 'Tasks',
        'teams': 'Teams',
        'profile': 'Profile',
        'about': 'About',
        'settings': 'Settings',
        
        // Tasks
        'createTask': 'Create Task',
        'editTask': 'Edit Task',
        'deleteTask': 'Delete Task',
        'taskName': 'Task Name',
        'taskDescription': 'Task Description',
        'taskSeverity': 'Task Severity',
        'taskCompleted': 'Task Completed',
        'assignedTo': 'Assigned To',
        'teamName': 'Team Name',
        'location': 'Location',
        'myTasks': 'My Tasks',
        'teamTasks': 'Team Tasks',
        'allTasks': 'All Tasks',
        
        // Task Severity Levels
        'severity1': 'Low (1)',
        'severity2': 'Low-Medium (2)',
        'severity3': 'Medium (3)',
        'severity4': 'High (4)',
        'severity5': 'Critical (5)',
        
        // Teams
        'createTeam': 'Create Team',
        'joinTeam': 'Join Team',
        'teamCode': 'Team Code',
        'generateCode': 'Generate Code',
        'teamMembers': 'Team Members',
        'removeMember': 'Remove Member',
        'closeTeam': 'Close Team',
        
        // Map
        'mapView': 'Map View',
        'listView': 'List View',
        'tapToCreateTask': 'Tap to create task',
        'currentLocation': 'Current Location',
        'searchLocation': 'Search Location',
        
        // Profile
        'editProfile': 'Edit Profile',
        'changeName': 'Change Name',
        'changeRole': 'Change Role',
        'accountType': 'Account Type',
        'role': 'Role',
        
        // About
        'aboutKapok': 'About Kapok',
        'aboutNCTDR': 'About NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'National Center for Technology and Dispute Resolution',
        'disasterReliefCoordination': 'Disaster Relief Coordination',
        
        // Settings
        'language': 'Language',
        'english': 'English',
        'spanish': 'Español',
        'notifications': 'Notifications',
        'offlineMode': 'Offline Mode',
        'syncData': 'Sync Data',
        
        // Status Messages
        'loading': 'Loading...',
        'saving': 'Saving...',
        'syncing': 'Syncing...',
        'offline': 'Offline',
        'online': 'Online',
        'error': 'Error',
        'success': 'Success',
        'warning': 'Warning',
        'info': 'Info',
        
        // Validation Messages
        'fieldRequired': 'This field is required',
        'emailInvalid': 'Please enter a valid email',
        'passwordTooShort': 'Password must be at least 6 characters',
        'passwordsDoNotMatch': 'Passwords do not match',
        'nameTooShort': 'Name must be at least 2 characters',
        'teamCodeInvalid': 'Please enter a valid team code',
        
        // Confirmation Messages
        'confirmDelete': 'Are you sure you want to delete this item?',
        'confirmSignOut': 'Are you sure you want to sign out?',
        'confirmCloseTeam': 'Are you sure you want to close this team?',
        'confirmRemoveMember': 'Are you sure you want to remove this member?',
        
        // Success Messages
        'taskCreated': 'Task created successfully',
        'taskUpdated': 'Task updated successfully',
        'taskDeleted': 'Task deleted successfully',
        'teamCreated': 'Team created successfully',
        'teamJoined': 'Successfully joined team',
        'profileUpdated': 'Profile updated successfully',
        'dataSynced': 'Data synced successfully',
        
        // Error Messages
        'networkError': 'Network error. Please check your connection.',
        'authError': 'Authentication error. Please try again.',
        'permissionDenied': 'Permission denied',
        'locationPermissionDenied': 'Location permission denied',
        'teamCodeNotFound': 'Team code not found',
        'teamAlreadyJoined': 'You are already a member of this team',
        'taskNotFound': 'Task not found',
        'teamNotFound': 'Team not found',
        'userNotFound': 'User not found',
      },
      'es': {
        // App Information
        'appName': 'Kapok',
        'appDescription': 'Aplicación de Coordinación de Ayuda en Desastres',
        'appVersion': '1.0.0',
        
        // Authentication
        'login': 'Iniciar Sesión',
        'createAccount': 'Crear Cuenta',
        'email': 'Correo Electrónico',
        'password': 'Contraseña',
        'confirmPassword': 'Confirmar Contraseña',
        'name': 'Nombre',
        'forgotPassword': '¿Olvidaste tu contraseña?',
        'signOut': 'Cerrar Sesión',
        
        // Account Types
        'admin': 'Administrador',
        'teamLeader': 'Líder de Equipo',
        'teamMember': 'Miembro del Equipo',
        
        // Roles
        'medical': 'Médico',
        'engineering': 'Ingeniería',
        'carpentry': 'Carpintería',
        'plumbing': 'Plomería',
        'construction': 'Construcción',
        'electrical': 'Eléctrico',
        'supplies': 'Suministros',
        'transportation': 'Transporte',
        'other': 'Otro',
        
        // Navigation
        'home': 'Inicio',
        'map': 'Mapa',
        'tasks': 'Tareas',
        'teams': 'Equipos',
        'profile': 'Perfil',
        'about': 'Acerca de',
        'settings': 'Configuración',
        
        // Tasks
        'createTask': 'Crear Tarea',
        'editTask': 'Editar Tarea',
        'deleteTask': 'Eliminar Tarea',
        'taskName': 'Nombre de la Tarea',
        'taskDescription': 'Descripción de la Tarea',
        'taskSeverity': 'Gravedad de la Tarea',
        'taskCompleted': 'Tarea Completada',
        'assignedTo': 'Asignado a',
        'teamName': 'Nombre del Equipo',
        'location': 'Ubicación',
        'myTasks': 'Mis Tareas',
        'teamTasks': 'Tareas del Equipo',
        'allTasks': 'Todas las Tareas',
        
        // Task Severity Levels
        'severity1': 'Baja (1)',
        'severity2': 'Baja-Media (2)',
        'severity3': 'Media (3)',
        'severity4': 'Alta (4)',
        'severity5': 'Crítica (5)',
        
        // Teams
        'createTeam': 'Crear Equipo',
        'joinTeam': 'Unirse al Equipo',
        'teamCode': 'Código del Equipo',
        'generateCode': 'Generar Código',
        'teamMembers': 'Miembros del Equipo',
        'removeMember': 'Eliminar Miembro',
        'closeTeam': 'Cerrar Equipo',
        
        // Map
        'mapView': 'Vista de Mapa',
        'listView': 'Vista de Lista',
        'tapToCreateTask': 'Toca para crear tarea',
        'currentLocation': 'Ubicación Actual',
        'searchLocation': 'Buscar Ubicación',
        
        // Profile
        'editProfile': 'Editar Perfil',
        'changeName': 'Cambiar Nombre',
        'changeRole': 'Cambiar Rol',
        'accountType': 'Tipo de Cuenta',
        'role': 'Rol',
        
        // About
        'aboutKapok': 'Acerca de Kapok',
        'aboutNCTDR': 'Acerca de NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'Centro Nacional de Tecnología y Resolución de Disputas',
        'disasterReliefCoordination': 'Coordinación de Ayuda en Desastres',
        
        // Settings
        'language': 'Idioma',
        'english': 'English',
        'spanish': 'Español',
        'notifications': 'Notificaciones',
        'offlineMode': 'Modo Sin Conexión',
        'syncData': 'Sincronizar Datos',
        
        // Status Messages
        'loading': 'Cargando...',
        'saving': 'Guardando...',
        'syncing': 'Sincronizando...',
        'offline': 'Sin Conexión',
        'online': 'En Línea',
        'error': 'Error',
        'success': 'Éxito',
        'warning': 'Advertencia',
        'info': 'Información',
        
        // Validation Messages
        'fieldRequired': 'Este campo es requerido',
        'emailInvalid': 'Por favor ingresa un correo válido',
        'passwordTooShort': 'La contraseña debe tener al menos 6 caracteres',
        'passwordsDoNotMatch': 'Las contraseñas no coinciden',
        'nameTooShort': 'El nombre debe tener al menos 2 caracteres',
        'teamCodeInvalid': 'Por favor ingresa un código de equipo válido',
        
        // Confirmation Messages
        'confirmDelete': '¿Estás seguro de que quieres eliminar este elemento?',
        'confirmSignOut': '¿Estás seguro de que quieres cerrar sesión?',
        'confirmCloseTeam': '¿Estás seguro de que quieres cerrar este equipo?',
        'confirmRemoveMember': '¿Estás seguro de que quieres eliminar este miembro?',
        
        // Success Messages
        'taskCreated': 'Tarea creada exitosamente',
        'taskUpdated': 'Tarea actualizada exitosamente',
        'taskDeleted': 'Tarea eliminada exitosamente',
        'teamCreated': 'Equipo creado exitosamente',
        'teamJoined': 'Te uniste al equipo exitosamente',
        'profileUpdated': 'Perfil actualizado exitosamente',
        'dataSynced': 'Datos sincronizados exitosamente',
        
        // Error Messages
        'networkError': 'Error de red. Por favor verifica tu conexión.',
        'authError': 'Error de autenticación. Por favor intenta de nuevo.',
        'permissionDenied': 'Permiso denegado',
        'locationPermissionDenied': 'Permiso de ubicación denegado',
        'teamCodeNotFound': 'Código de equipo no encontrado',
        'teamAlreadyJoined': 'Ya eres miembro de este equipo',
        'taskNotFound': 'Tarea no encontrada',
        'teamNotFound': 'Equipo no encontrado',
        'userNotFound': 'Usuario no encontrado',
      },
    };

    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
