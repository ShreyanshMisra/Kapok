---
title: Localization and Translation
description: Comprehensive guide to implementing multi-language support in the Kapok application
---

# Localization and Translation

## Overview

The Kapok application supports **English** and **Spanish** languages to serve diverse disaster relief teams. This document covers the implementation of internationalization (i18n) and localization (l10n) features, including dynamic language switching and comprehensive translation coverage.

## Supported Languages

### Primary Languages
- **English (en)** - Default language
- **Spanish (es)** - Secondary language

### Future Language Support
- Additional languages can be easily added following the established patterns
- Language-specific formatting (dates, numbers, currency)
- Right-to-left (RTL) language support for future expansion

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    UI       │ │    UI       │ │    UI       │          │
│  │  Widgets    │ │  Widgets    │ │  Widgets    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                Localization Layer                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ AppLocal-   │ │ Language    │ │ Translation │          │
│  │ izations    │ │  Manager    │ │   Service   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Translation Files                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   en.arb    │ │   es.arb    │ │  Generated  │          │
│  │  (English)  │ │  (Spanish)  │ │    Code     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Structure

### Core Localization Files

```
lib/core/localization/
├── app_localizations.dart    # Main localization class
├── en.arb                   # English translations
└── es.arb                   # Spanish translations
```

### Generated Files

```
lib/generated/
├── l10n.dart               # Generated localization code
└── app_localizations_*.dart # Language-specific files
```

## Translation Files

### English Translations (`en.arb`)

```json
{
  "@@locale": "en",
  "appName": "Kapok",
  "@appName": {
    "description": "The name of the application"
  },
  "appDescription": "Disaster Relief Coordination App",
  "@appDescription": {
    "description": "Brief description of the application"
  },
  "appVersion": "1.0.0",
  "@appVersion": {
    "description": "Current version of the application"
  },
  
  "login": "Login",
  "@login": {
    "description": "Login button text"
  },
  "createAccount": "Create Account",
  "@createAccount": {
    "description": "Create account button text"
  },
  "email": "Email",
  "@email": {
    "description": "Email field label"
  },
  "password": "Password",
  "@password": {
    "description": "Password field label"
  },
  "confirmPassword": "Confirm Password",
  "@confirmPassword": {
    "description": "Confirm password field label"
  },
  "name": "Name",
  "@name": {
    "description": "Name field label"
  },
  "forgotPassword": "Forgot Password?",
  "@forgotPassword": {
    "description": "Forgot password link text"
  },
  "signOut": "Sign Out",
  "@signOut": {
    "description": "Sign out button text"
  },
  
  "admin": "Admin",
  "@admin": {
    "description": "Admin account type"
  },
  "teamLeader": "Team Leader",
  "@teamLeader": {
    "description": "Team leader account type"
  },
  "teamMember": "Team Member",
  "@teamMember": {
    "description": "Team member account type"
  },
  
  "medical": "Medical",
  "@medical": {
    "description": "Medical role"
  },
  "engineering": "Engineering",
  "@engineering": {
    "description": "Engineering role"
  },
  "carpentry": "Carpentry",
  "@carpentry": {
    "description": "Carpentry role"
  },
  "plumbing": "Plumbing",
  "@plumbing": {
    "description": "Plumbing role"
  },
  "construction": "Construction",
  "@construction": {
    "description": "Construction role"
  },
  "electrical": "Electrical",
  "@electrical": {
    "description": "Electrical role"
  },
  "supplies": "Supplies",
  "@supplies": {
    "description": "Supplies role"
  },
  "transportation": "Transportation",
  "@transportation": {
    "description": "Transportation role"
  },
  "other": "Other",
  "@other": {
    "description": "Other role"
  },
  
  "home": "Home",
  "@home": {
    "description": "Home navigation item"
  },
  "map": "Map",
  "@map": {
    "description": "Map navigation item"
  },
  "tasks": "Tasks",
  "@tasks": {
    "description": "Tasks navigation item"
  },
  "teams": "Teams",
  "@teams": {
    "description": "Teams navigation item"
  },
  "profile": "Profile",
  "@profile": {
    "description": "Profile navigation item"
  },
  "about": "About",
  "@about": {
    "description": "About navigation item"
  },
  "settings": "Settings",
  "@settings": {
    "description": "Settings navigation item"
  },
  
  "createTask": "Create Task",
  "@createTask": {
    "description": "Create task button text"
  },
  "editTask": "Edit Task",
  "@editTask": {
    "description": "Edit task button text"
  },
  "deleteTask": "Delete Task",
  "@deleteTask": {
    "description": "Delete task button text"
  },
  "taskName": "Task Name",
  "@taskName": {
    "description": "Task name field label"
  },
  "taskDescription": "Task Description",
  "@taskDescription": {
    "description": "Task description field label"
  },
  "taskSeverity": "Task Severity",
  "@taskSeverity": {
    "description": "Task severity field label"
  },
  "taskCompleted": "Task Completed",
  "@taskCompleted": {
    "description": "Task completed checkbox label"
  },
  "assignedTo": "Assigned To",
  "@assignedTo": {
    "description": "Assigned to field label"
  },
  "teamName": "Team Name",
  "@teamName": {
    "description": "Team name field label"
  },
  "location": "Location",
  "@location": {
    "description": "Location field label"
  },
  "myTasks": "My Tasks",
  "@myTasks": {
    "description": "My tasks filter option"
  },
  "teamTasks": "Team Tasks",
  "@teamTasks": {
    "description": "Team tasks filter option"
  },
  "allTasks": "All Tasks",
  "@allTasks": {
    "description": "All tasks filter option"
  },
  
  "severity1": "Low (1)",
  "@severity1": {
    "description": "Task severity level 1"
  },
  "severity2": "Low-Medium (2)",
  "@severity2": {
    "description": "Task severity level 2"
  },
  "severity3": "Medium (3)",
  "@severity3": {
    "description": "Task severity level 3"
  },
  "severity4": "High (4)",
  "@severity4": {
    "description": "Task severity level 4"
  },
  "severity5": "Critical (5)",
  "@severity5": {
    "description": "Task severity level 5"
  },
  
  "createTeam": "Create Team",
  "@createTeam": {
    "description": "Create team button text"
  },
  "joinTeam": "Join Team",
  "@joinTeam": {
    "description": "Join team button text"
  },
  "teamCode": "Team Code",
  "@teamCode": {
    "description": "Team code field label"
  },
  "generateCode": "Generate Code",
  "@generateCode": {
    "description": "Generate code button text"
  },
  "teamMembers": "Team Members",
  "@teamMembers": {
    "description": "Team members section title"
  },
  "removeMember": "Remove Member",
  "@removeMember": {
    "description": "Remove member button text"
  },
  "closeTeam": "Close Team",
  "@closeTeam": {
    "description": "Close team button text"
  },
  
  "mapView": "Map View",
  "@mapView": {
    "description": "Map view option"
  },
  "listView": "List View",
  "@listView": {
    "description": "List view option"
  },
  "tapToCreateTask": "Tap to create task",
  "@tapToCreateTask": {
    "description": "Map tap instruction"
  },
  "currentLocation": "Current Location",
  "@currentLocation": {
    "description": "Current location button text"
  },
  "searchLocation": "Search Location",
  "@searchLocation": {
    "description": "Search location field placeholder"
  },
  
  "editProfile": "Edit Profile",
  "@editProfile": {
    "description": "Edit profile button text"
  },
  "changeName": "Change Name",
  "@changeName": {
    "description": "Change name button text"
  },
  "changeRole": "Change Role",
  "@changeRole": {
    "description": "Change role button text"
  },
  "accountType": "Account Type",
  "@accountType": {
    "description": "Account type field label"
  },
  "role": "Role",
  "@role": {
    "description": "Role field label"
  },
  
  "aboutKapok": "About Kapok",
  "@aboutKapok": {
    "description": "About Kapok section title"
  },
  "aboutNCTDR": "About NCTDR",
  "@aboutNCTDR": {
    "description": "About NCTDR section title"
  },
  "nationalCenterForTechnologyAndDisputeResolution": "National Center for Technology and Dispute Resolution",
  "@nationalCenterForTechnologyAndDisputeResolution": {
    "description": "Full name of NCTDR"
  },
  "disasterReliefCoordination": "Disaster Relief Coordination",
  "@disasterReliefCoordination": {
    "description": "Description of app purpose"
  },
  
  "language": "Language",
  "@language": {
    "description": "Language setting label"
  },
  "english": "English",
  "@english": {
    "description": "English language option"
  },
  "spanish": "Español",
  "@spanish": {
    "description": "Spanish language option"
  },
  "notifications": "Notifications",
  "@notifications": {
    "description": "Notifications setting label"
  },
  "offlineMode": "Offline Mode",
  "@offlineMode": {
    "description": "Offline mode setting label"
  },
  "syncData": "Sync Data",
  "@syncData": {
    "description": "Sync data button text"
  },
  
  "loading": "Loading...",
  "@loading": {
    "description": "Loading indicator text"
  },
  "saving": "Saving...",
  "@saving": {
    "description": "Saving indicator text"
  },
  "syncing": "Syncing...",
  "@syncing": {
    "description": "Syncing indicator text"
  },
  "offline": "Offline",
  "@offline": {
    "description": "Offline status text"
  },
  "online": "Online",
  "@online": {
    "description": "Online status text"
  },
  "error": "Error",
  "@error": {
    "description": "Error status text"
  },
  "success": "Success",
  "@success": {
    "description": "Success status text"
  },
  "warning": "Warning",
  "@warning": {
    "description": "Warning status text"
  },
  "info": "Info",
  "@info": {
    "description": "Info status text"
  },
  
  "fieldRequired": "This field is required",
  "@fieldRequired": {
    "description": "Required field validation message"
  },
  "emailInvalid": "Please enter a valid email",
  "@emailInvalid": {
    "description": "Invalid email validation message"
  },
  "passwordTooShort": "Password must be at least 6 characters",
  "@passwordTooShort": {
    "description": "Password too short validation message"
  },
  "passwordsDoNotMatch": "Passwords do not match",
  "@passwordsDoNotMatch": {
    "description": "Password mismatch validation message"
  },
  "nameTooShort": "Name must be at least 2 characters",
  "@nameTooShort": {
    "description": "Name too short validation message"
  },
  "teamCodeInvalid": "Please enter a valid team code",
  "@teamCodeInvalid": {
    "description": "Invalid team code validation message"
  },
  
  "confirmDelete": "Are you sure you want to delete this item?",
  "@confirmDelete": {
    "description": "Delete confirmation message"
  },
  "confirmSignOut": "Are you sure you want to sign out?",
  "@confirmSignOut": {
    "description": "Sign out confirmation message"
  },
  "confirmCloseTeam": "Are you sure you want to close this team?",
  "@confirmCloseTeam": {
    "description": "Close team confirmation message"
  },
  "confirmRemoveMember": "Are you sure you want to remove this member?",
  "@confirmRemoveMember": {
    "description": "Remove member confirmation message"
  },
  
  "taskCreated": "Task created successfully",
  "@taskCreated": {
    "description": "Task created success message"
  },
  "taskUpdated": "Task updated successfully",
  "@taskUpdated": {
    "description": "Task updated success message"
  },
  "taskDeleted": "Task deleted successfully",
  "@taskDeleted": {
    "description": "Task deleted success message"
  },
  "teamCreated": "Team created successfully",
  "@teamCreated": {
    "description": "Team created success message"
  },
  "teamJoined": "Successfully joined team",
  "@teamJoined": {
    "description": "Team joined success message"
  },
  "profileUpdated": "Profile updated successfully",
  "@profileUpdated": {
    "description": "Profile updated success message"
  },
  "dataSynced": "Data synced successfully",
  "@dataSynced": {
    "description": "Data synced success message"
  },
  
  "networkError": "Network error. Please check your connection.",
  "@networkError": {
    "description": "Network error message"
  },
  "authError": "Authentication error. Please try again.",
  "@authError": {
    "description": "Authentication error message"
  },
  "permissionDenied": "Permission denied",
  "@permissionDenied": {
    "description": "Permission denied message"
  },
  "locationPermissionDenied": "Location permission denied",
  "@locationPermissionDenied": {
    "description": "Location permission denied message"
  },
  "teamCodeNotFound": "Team code not found",
  "@teamCodeNotFound": {
    "description": "Team code not found message"
  },
  "teamAlreadyJoined": "You are already a member of this team",
  "@teamAlreadyJoined": {
    "description": "Team already joined message"
  },
  "taskNotFound": "Task not found",
  "@taskNotFound": {
    "description": "Task not found message"
  },
  "teamNotFound": "Team not found",
  "@teamNotFound": {
    "description": "Team not found message"
  },
  "userNotFound": "User not found",
  "@userNotFound": {
    "description": "User not found message"
  }
}
```

### Spanish Translations (`es.arb`)

```json
{
  "@@locale": "es",
  "appName": "Kapok",
  "appDescription": "Aplicación de Coordinación de Ayuda en Desastres",
  "appVersion": "1.0.0",
  
  "login": "Iniciar Sesión",
  "createAccount": "Crear Cuenta",
  "email": "Correo Electrónico",
  "password": "Contraseña",
  "confirmPassword": "Confirmar Contraseña",
  "name": "Nombre",
  "forgotPassword": "¿Olvidaste tu contraseña?",
  "signOut": "Cerrar Sesión",
  
  "admin": "Administrador",
  "teamLeader": "Líder de Equipo",
  "teamMember": "Miembro del Equipo",
  
  "medical": "Médico",
  "engineering": "Ingeniería",
  "carpentry": "Carpintería",
  "plumbing": "Plomería",
  "construction": "Construcción",
  "electrical": "Eléctrico",
  "supplies": "Suministros",
  "transportation": "Transporte",
  "other": "Otro",
  
  "home": "Inicio",
  "map": "Mapa",
  "tasks": "Tareas",
  "teams": "Equipos",
  "profile": "Perfil",
  "about": "Acerca de",
  "settings": "Configuración",
  
  "createTask": "Crear Tarea",
  "editTask": "Editar Tarea",
  "deleteTask": "Eliminar Tarea",
  "taskName": "Nombre de la Tarea",
  "taskDescription": "Descripción de la Tarea",
  "taskSeverity": "Gravedad de la Tarea",
  "taskCompleted": "Tarea Completada",
  "assignedTo": "Asignado a",
  "teamName": "Nombre del Equipo",
  "location": "Ubicación",
  "myTasks": "Mis Tareas",
  "teamTasks": "Tareas del Equipo",
  "allTasks": "Todas las Tareas",
  
  "severity1": "Baja (1)",
  "severity2": "Baja-Media (2)",
  "severity3": "Media (3)",
  "severity4": "Alta (4)",
  "severity5": "Crítica (5)",
  
  "createTeam": "Crear Equipo",
  "joinTeam": "Unirse al Equipo",
  "teamCode": "Código del Equipo",
  "generateCode": "Generar Código",
  "teamMembers": "Miembros del Equipo",
  "removeMember": "Eliminar Miembro",
  "closeTeam": "Cerrar Equipo",
  
  "mapView": "Vista de Mapa",
  "listView": "Vista de Lista",
  "tapToCreateTask": "Toca para crear tarea",
  "currentLocation": "Ubicación Actual",
  "searchLocation": "Buscar Ubicación",
  
  "editProfile": "Editar Perfil",
  "changeName": "Cambiar Nombre",
  "changeRole": "Cambiar Rol",
  "accountType": "Tipo de Cuenta",
  "role": "Rol",
  
  "aboutKapok": "Acerca de Kapok",
  "aboutNCTDR": "Acerca de NCTDR",
  "nationalCenterForTechnologyAndDisputeResolution": "Centro Nacional de Tecnología y Resolución de Disputas",
  "disasterReliefCoordination": "Coordinación de Ayuda en Desastres",
  
  "language": "Idioma",
  "english": "English",
  "spanish": "Español",
  "notifications": "Notificaciones",
  "offlineMode": "Modo Sin Conexión",
  "syncData": "Sincronizar Datos",
  
  "loading": "Cargando...",
  "saving": "Guardando...",
  "syncing": "Sincronizando...",
  "offline": "Sin Conexión",
  "online": "En Línea",
  "error": "Error",
  "success": "Éxito",
  "warning": "Advertencia",
  "info": "Información",
  
  "fieldRequired": "Este campo es requerido",
  "emailInvalid": "Por favor ingresa un correo válido",
  "passwordTooShort": "La contraseña debe tener al menos 6 caracteres",
  "passwordsDoNotMatch": "Las contraseñas no coinciden",
  "nameTooShort": "El nombre debe tener al menos 2 caracteres",
  "teamCodeInvalid": "Por favor ingresa un código de equipo válido",
  
  "confirmDelete": "¿Estás seguro de que quieres eliminar este elemento?",
  "confirmSignOut": "¿Estás seguro de que quieres cerrar sesión?",
  "confirmCloseTeam": "¿Estás seguro de que quieres cerrar este equipo?",
  "confirmRemoveMember": "¿Estás seguro de que quieres eliminar este miembro?",
  
  "taskCreated": "Tarea creada exitosamente",
  "taskUpdated": "Tarea actualizada exitosamente",
  "taskDeleted": "Tarea eliminada exitosamente",
  "teamCreated": "Equipo creado exitosamente",
  "teamJoined": "Te uniste al equipo exitosamente",
  "profileUpdated": "Perfil actualizado exitosamente",
  "dataSynced": "Datos sincronizados exitosamente",
  
  "networkError": "Error de red. Por favor verifica tu conexión.",
  "authError": "Error de autenticación. Por favor intenta de nuevo.",
  "permissionDenied": "Permiso denegado",
  "locationPermissionDenied": "Permiso de ubicación denegado",
  "teamCodeNotFound": "Código de equipo no encontrado",
  "teamAlreadyJoined": "Ya eres miembro de este equipo",
  "taskNotFound": "Tarea no encontrada",
  "teamNotFound": "Equipo no encontrado",
  "userNotFound": "Usuario no encontrado"
}
```

## App Localizations Implementation

### Main Localization Class

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

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
        // English translations
        'appName': 'Kapok',
        'appDescription': 'Disaster Relief Coordination App',
        'appVersion': '1.0.0',
        'login': 'Login',
        'createAccount': 'Create Account',
        'email': 'Email',
        'password': 'Password',
        'confirmPassword': 'Confirm Password',
        'name': 'Name',
        'forgotPassword': 'Forgot Password?',
        'signOut': 'Sign Out',
        'admin': 'Admin',
        'teamLeader': 'Team Leader',
        'teamMember': 'Team Member',
        'medical': 'Medical',
        'engineering': 'Engineering',
        'carpentry': 'Carpentry',
        'plumbing': 'Plumbing',
        'construction': 'Construction',
        'electrical': 'Electrical',
        'supplies': 'Supplies',
        'transportation': 'Transportation',
        'other': 'Other',
        'home': 'Home',
        'map': 'Map',
        'tasks': 'Tasks',
        'teams': 'Teams',
        'profile': 'Profile',
        'about': 'About',
        'settings': 'Settings',
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
        'severity1': 'Low (1)',
        'severity2': 'Low-Medium (2)',
        'severity3': 'Medium (3)',
        'severity4': 'High (4)',
        'severity5': 'Critical (5)',
        'createTeam': 'Create Team',
        'joinTeam': 'Join Team',
        'teamCode': 'Team Code',
        'generateCode': 'Generate Code',
        'teamMembers': 'Team Members',
        'removeMember': 'Remove Member',
        'closeTeam': 'Close Team',
        'mapView': 'Map View',
        'listView': 'List View',
        'tapToCreateTask': 'Tap to create task',
        'currentLocation': 'Current Location',
        'searchLocation': 'Search Location',
        'editProfile': 'Edit Profile',
        'changeName': 'Change Name',
        'changeRole': 'Change Role',
        'accountType': 'Account Type',
        'role': 'Role',
        'aboutKapok': 'About Kapok',
        'aboutNCTDR': 'About NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'National Center for Technology and Dispute Resolution',
        'disasterReliefCoordination': 'Disaster Relief Coordination',
        'language': 'Language',
        'english': 'English',
        'spanish': 'Español',
        'notifications': 'Notifications',
        'offlineMode': 'Offline Mode',
        'syncData': 'Sync Data',
        'loading': 'Loading...',
        'saving': 'Saving...',
        'syncing': 'Syncing...',
        'offline': 'Offline',
        'online': 'Online',
        'error': 'Error',
        'success': 'Success',
        'warning': 'Warning',
        'info': 'Info',
        'fieldRequired': 'This field is required',
        'emailInvalid': 'Please enter a valid email',
        'passwordTooShort': 'Password must be at least 6 characters',
        'passwordsDoNotMatch': 'Passwords do not match',
        'nameTooShort': 'Name must be at least 2 characters',
        'teamCodeInvalid': 'Please enter a valid team code',
        'confirmDelete': 'Are you sure you want to delete this item?',
        'confirmSignOut': 'Are you sure you want to sign out?',
        'confirmCloseTeam': 'Are you sure you want to close this team?',
        'confirmRemoveMember': 'Are you sure you want to remove this member?',
        'taskCreated': 'Task created successfully',
        'taskUpdated': 'Task updated successfully',
        'taskDeleted': 'Task deleted successfully',
        'teamCreated': 'Team created successfully',
        'teamJoined': 'Successfully joined team',
        'profileUpdated': 'Profile updated successfully',
        'dataSynced': 'Data synced successfully',
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
        // Spanish translations
        'appName': 'Kapok',
        'appDescription': 'Aplicación de Coordinación de Ayuda en Desastres',
        'appVersion': '1.0.0',
        'login': 'Iniciar Sesión',
        'createAccount': 'Crear Cuenta',
        'email': 'Correo Electrónico',
        'password': 'Contraseña',
        'confirmPassword': 'Confirmar Contraseña',
        'name': 'Nombre',
        'forgotPassword': '¿Olvidaste tu contraseña?',
        'signOut': 'Cerrar Sesión',
        'admin': 'Administrador',
        'teamLeader': 'Líder de Equipo',
        'teamMember': 'Miembro del Equipo',
        'medical': 'Médico',
        'engineering': 'Ingeniería',
        'carpentry': 'Carpintería',
        'plumbing': 'Plomería',
        'construction': 'Construcción',
        'electrical': 'Eléctrico',
        'supplies': 'Suministros',
        'transportation': 'Transporte',
        'other': 'Otro',
        'home': 'Inicio',
        'map': 'Mapa',
        'tasks': 'Tareas',
        'teams': 'Equipos',
        'profile': 'Perfil',
        'about': 'Acerca de',
        'settings': 'Configuración',
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
        'severity1': 'Baja (1)',
        'severity2': 'Baja-Media (2)',
        'severity3': 'Media (3)',
        'severity4': 'Alta (4)',
        'severity5': 'Crítica (5)',
        'createTeam': 'Crear Equipo',
        'joinTeam': 'Unirse al Equipo',
        'teamCode': 'Código del Equipo',
        'generateCode': 'Generar Código',
        'teamMembers': 'Miembros del Equipo',
        'removeMember': 'Eliminar Miembro',
        'closeTeam': 'Cerrar Equipo',
        'mapView': 'Vista de Mapa',
        'listView': 'Vista de Lista',
        'tapToCreateTask': 'Toca para crear tarea',
        'currentLocation': 'Ubicación Actual',
        'searchLocation': 'Buscar Ubicación',
        'editProfile': 'Editar Perfil',
        'changeName': 'Cambiar Nombre',
        'changeRole': 'Cambiar Rol',
        'accountType': 'Tipo de Cuenta',
        'role': 'Rol',
        'aboutKapok': 'Acerca de Kapok',
        'aboutNCTDR': 'Acerca de NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'Centro Nacional de Tecnología y Resolución de Disputas',
        'disasterReliefCoordination': 'Coordinación de Ayuda en Desastres',
        'language': 'Idioma',
        'english': 'English',
        'spanish': 'Español',
        'notifications': 'Notificaciones',
        'offlineMode': 'Modo Sin Conexión',
        'syncData': 'Sincronizar Datos',
        'loading': 'Cargando...',
        'saving': 'Guardando...',
        'syncing': 'Sincronizando...',
        'offline': 'Sin Conexión',
        'online': 'En Línea',
        'error': 'Error',
        'success': 'Éxito',
        'warning': 'Advertencia',
        'info': 'Información',
        'fieldRequired': 'Este campo es requerido',
        'emailInvalid': 'Por favor ingresa un correo válido',
        'passwordTooShort': 'La contraseña debe tener al menos 6 caracteres',
        'passwordsDoNotMatch': 'Las contraseñas no coinciden',
        'nameTooShort': 'El nombre debe tener al menos 2 caracteres',
        'teamCodeInvalid': 'Por favor ingresa un código de equipo válido',
        'confirmDelete': '¿Estás seguro de que quieres eliminar este elemento?',
        'confirmSignOut': '¿Estás seguro de que quieres cerrar sesión?',
        'confirmCloseTeam': '¿Estás seguro de que quieres cerrar este equipo?',
        'confirmRemoveMember': '¿Estás seguro de que quieres eliminar este miembro?',
        'taskCreated': 'Tarea creada exitosamente',
        'taskUpdated': 'Tarea actualizada exitosamente',
        'taskDeleted': 'Tarea eliminada exitosamente',
        'teamCreated': 'Equipo creado exitosamente',
        'teamJoined': 'Te uniste al equipo exitosamente',
        'profileUpdated': 'Perfil actualizado exitosamente',
        'dataSynced': 'Datos sincronizados exitosamente',
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
```

## Language Management

### Language Manager Service

```dart
class LanguageManager {
  static const String _languageKey = 'selected_language';
  static const Locale defaultLocale = Locale('en');
  
  static Locale getCurrentLocale() {
    final languageCode = HiveService.instance.getSetting<String>(_languageKey);
    return languageCode != null ? Locale(languageCode) : defaultLocale;
  }
  
  static Future<void> setLanguage(Locale locale) async {
    await HiveService.instance.storeSetting(_languageKey, locale.languageCode);
  }
  
  static List<Locale> getSupportedLocales() {
    return AppLocalizations.supportedLocales;
  }
  
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }
}
```

### Language Selection Widget

```dart
class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context).language),
      subtitle: Text(LanguageManager.getLanguageName(currentLocale)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showLanguageDialog(context);
      },
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocalizations.supportedLocales.map((locale) {
            return ListTile(
              title: Text(LanguageManager.getLanguageName(locale)),
              trailing: Localizations.localeOf(context) == locale
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                _changeLanguage(context, locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _changeLanguage(BuildContext context, Locale locale) async {
    await LanguageManager.setLanguage(locale);
    
    // Restart app with new language
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const KapokApp(),
      ),
      (route) => false,
    );
  }
}
```

## App Configuration

### MaterialApp Setup

```dart
class KapokApp extends StatelessWidget {
  const KapokApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kapok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: LanguageManager.getCurrentLocale(),
      home: const HomePage(),
    );
  }
}
```

### pubspec.yaml Configuration

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

flutter:
  generate: true
```

### l10n.yaml Configuration

```yaml
arb-dir: lib/core/localization
template-arb-file: en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

## Usage in UI

### Basic Usage

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: l10n.email,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.password,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }
}
```

### Dynamic Text Updates

```dart
class TaskCard extends StatelessWidget {
  final TaskModel task;
  
  const TaskCard({Key? key, required this.task}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: ListTile(
        title: Text(task.taskName),
        subtitle: Text(task.taskDescription),
        trailing: Text(
          task.taskCompleted ? l10n.taskCompleted : l10n.taskName,
        ),
      ),
    );
  }
}
```

### Form Validation

```dart
class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.taskName,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.taskDescription,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
```

## Testing Localization

### Unit Tests

```dart
void main() {
  group('AppLocalizations', () {
    test('should return English strings for en locale', () {
      final l10n = AppLocalizations(const Locale('en'));
      
      expect(l10n.appName, 'Kapok');
      expect(l10n.login, 'Login');
      expect(l10n.createAccount, 'Create Account');
    });
    
    test('should return Spanish strings for es locale', () {
      final l10n = AppLocalizations(const Locale('es'));
      
      expect(l10n.appName, 'Kapok');
      expect(l10n.login, 'Iniciar Sesión');
      expect(l10n.createAccount, 'Crear Cuenta');
    });
    
    test('should fallback to key for unsupported locale', () {
      final l10n = AppLocalizations(const Locale('fr'));
      
      expect(l10n.login, 'login');
      expect(l10n.createAccount, 'createAccount');
    });
  });
}
```

### Widget Tests

```dart
void main() {
  group('Localized Widget Tests', () {
    testWidgets('should display English text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LoginPage(),
        ),
      );
      
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });
    
    testWidgets('should display Spanish text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: const LoginPage(),
        ),
      );
      
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Correo Electrónico'), findsOneWidget);
    });
  });
}
```

## Best Practices

### 1. Translation Management

- **Consistent Naming**: Use consistent key naming conventions
- **Descriptive Keys**: Use descriptive keys that indicate context
- **Documentation**: Include descriptions for translators
- **Validation**: Validate all translations are present

### 2. Code Organization

- **Centralized**: Keep all translations in one place
- **Modular**: Organize translations by feature when needed
- **Type Safety**: Use generated code for type safety
- **Fallbacks**: Always provide fallback values

### 3. User Experience

- **Language Persistence**: Remember user's language choice
- **Smooth Transitions**: Provide smooth language switching
- **Context Awareness**: Use appropriate translations for context
- **Accessibility**: Ensure translations are accessible

### 4. Performance

- **Lazy Loading**: Load translations only when needed
- **Caching**: Cache frequently used translations
- **Minimal Bundle**: Include only necessary translations
- **Efficient Updates**: Update only changed translations

---

*This localization and translation documentation provides comprehensive guidance for implementing multi-language support in the Kapok application. Follow these patterns to ensure consistent and maintainable internationalization.*

