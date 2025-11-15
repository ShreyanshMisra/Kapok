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
  bool shouldReload(AppLocalizationsDelegate old) => true;
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
  String get noTasksYet => _getString('noTasksYet');
  String get createYourFirstTaskToGetStarted => _getString('createYourFirstTaskToGetStarted');
  String get errorLoadingTasks => _getString('errorLoadingTasks');
  String get retry => _getString('retry');
  String get completed => _getString('completed');
  String get open => _getString('open');
  String get high => _getString('high');
  String get medium => _getString('medium');
  String get low => _getString('low');
  String get assignedToLabel => _getString('assignedToLabel');

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
  String get locationServices => _getString('locationServices');
  String get appearance => _getString('appearance');
  String get theme => _getString('theme');
  String get data => _getString('data');
  String get clearCache => _getString('clearCache');
  String get exportData => _getString('exportData');
  String get appVersionLabel => _getString('appVersionLabel');
  String get privacyPolicy => _getString('privacyPolicy');
  String get termsOfService => _getString('termsOfService');
  String get close => _getString('close');
  String get cancel => _getString('cancel');
  String get clear => _getString('clear');
  String get export => _getString('export');
  String get selectTheme => _getString('selectTheme');
  String get system => _getString('system');
  String get light => _getString('light');
  String get dark => _getString('dark');
  String get receiveNotificationsForNewTasksAndUpdates => _getString('receiveNotificationsForNewTasksAndUpdates');
  String get allowAppToAccessYourLocationForTaskMapping => _getString('allowAppToAccessYourLocationForTaskMapping');
  String get clearLocallyStoredData => _getString('clearLocallyStoredData');
  String get exportYourTasksAndTeamData => _getString('exportYourTasksAndTeamData');
  String get thisWillClearAllLocallyStoredDataYouWillNeedToSignInAgain => _getString('thisWillClearAllLocallyStoredDataYouWillNeedToSignInAgain');
  String get thisWillExportYourTasksAndTeamDataToAFile => _getString('thisWillExportYourTasksAndTeamDataToAFile');
  String get cacheClearedSuccessfully => _getString('cacheClearedSuccessfully');
  String get dataExportNotImplementedYet => _getString('dataExportNotImplementedYet');

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

  // Additional UI Strings
  String get signIn => _getString('signIn');
  String get dontHaveAnAccount => _getString('dontHaveAnAccount');
  String get signUp => _getString('signUp');
  String get userNotAuthenticated => _getString('userNotAuthenticated');
  String get accountInformation => _getString('accountInformation');
  String get teamId => _getString('teamId');
  String get ourMission => _getString('ourMission');
  String get ourMissionDescription => _getString('ourMissionDescription');
  String get nctdrDescription => _getString('nctdrDescription');
  String get keyFeatures => _getString('keyFeatures');
  String get keyFeaturesDescription => _getString('keyFeaturesDescription');
  String get technology => _getString('technology');
  String get technologyDescription => _getString('technologyDescription');
  String get contactAndSupport => _getString('contactAndSupport');
  String get contactAndSupportDescription => _getString('contactAndSupportDescription');
  String get builtWithLove => _getString('builtWithLove');
  String get legal => _getString('legal');
  String get legalDescription => _getString('legalDescription');
  String get myTeams => _getString('myTeams');
  String get errorLoadingTeams => _getString('errorLoadingTeams');
  String get createNewTask => _getString('createNewTask');
  String get createANewTaskOrLog => _getString('createANewTaskOrLog');
  String get enterTaskTitle => _getString('enterTaskTitle');
  String get enterTaskDescription => _getString('enterTaskDescription');
  String get enterTaskLocationOrLeaveEmptyForCurrentLocation => _getString('enterTaskLocationOrLeaveEmptyForCurrentLocation');
  String get enterUserEmailOrId => _getString('enterUserEmailOrId');
  String get markAsCompleted => _getString('markAsCompleted');
  String get checkIfThisTaskIsAlreadyCompleted => _getString('checkIfThisTaskIsAlreadyCompleted');
  String get save => _getString('save');
  String get youMustBeLoggedInToCreateTasks => _getString('youMustBeLoggedInToCreateTasks');
  String get taskCreatedSuccessfully => _getString('taskCreatedSuccessfully');
  String get mapPageToBeImplemented => _getString('mapPageToBeImplemented');
  String get noTeamsYet => _getString('noTeamsYet');
  String get createYourFirstTeamToGetStarted => _getString('createYourFirstTeamToGetStarted');
  String get member => _getString('member');
  String get members => _getString('members');
  String get active => _getString('active');
  String get inactive => _getString('inactive');
  String get joinAnExistingTeamOrCreateANewOneToGetStarted => _getString('joinAnExistingTeamOrCreateANewOneToGetStarted');
  String get taskTitle => _getString('taskTitle');
  String get description => _getString('description');
  String get priority => _getString('priority');
  String get assignedToOptional => _getString('assignedToOptional');
  String get taskInformation => _getString('taskInformation');
  String get taskInformationDescription => _getString('taskInformationDescription');
  String get pleaseEnterADescription => _getString('pleaseEnterADescription');
  String get pleaseEnterALocation => _getString('pleaseEnterALocation');
  String get fullName => _getString('fullName');
  String get resetPassword => _getString('resetPassword');
  String get resetYourPassword => _getString('resetYourPassword');
  String get resetPasswordDescription => _getString('resetPasswordDescription');
  String get resetPasswordEmailSentDescription => _getString('resetPasswordEmailSentDescription');
  String get emailAddress => _getString('emailAddress');
  String get sendResetEmail => _getString('sendResetEmail');
  String get emailSentSuccessfully => _getString('emailSentSuccessfully');
  String get backToLogin => _getString('backToLogin');
  String get resetPasswordHelpText => _getString('resetPasswordHelpText');
  String get passwordResetEmailSentTo => _getString('passwordResetEmailSentTo');
  String get byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy => _getString('byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy');
  String get createNewTeam => _getString('createNewTeam');
  String get setUpANewTeamForDisasterReliefCoordination => _getString('setUpANewTeamForDisasterReliefCoordination');
  String get enterTeamName => _getString('enterTeamName');
  String get descriptionOptional => _getString('descriptionOptional');
  String get briefDescriptionOfTheTeamsPurpose => _getString('briefDescriptionOfTheTeamsPurpose');
  String get teamLeaderBenefits => _getString('teamLeaderBenefits');
  String get teamLeaderBenefitsDescription => _getString('teamLeaderBenefitsDescription');
  String get teamCreatedSuccessfullyWithCode => _getString('teamCreatedSuccessfullyWithCode');
  String get youMustBeLoggedInToCreateTeams => _getString('youMustBeLoggedInToCreateTeams');
  String get joinATeam => _getString('joinATeam');
  String get enterTheTeamCodeProvidedByYourTeamLeader => _getString('enterTheTeamCodeProvidedByYourTeamLeader');
  String get enter6CharacterTeamCode => _getString('enter6CharacterTeamCode');
  String get pleaseEnterATeamCode => _getString('pleaseEnterATeamCode');
  String get teamCodeMustBe6Characters => _getString('teamCodeMustBe6Characters');
  String get howToGetATeamCode => _getString('howToGetATeamCode');
  String get howToGetATeamCodeDescription => _getString('howToGetATeamCodeDescription');
  String get dontHaveATeamCodeCreateANewTeam => _getString('dontHaveATeamCodeCreateANewTeam');
  String get youMustBeLoggedInToJoinTeams => _getString('youMustBeLoggedInToJoinTeams');
  String get successfullyJoinedTeam => _getString('successfullyJoinedTeam');
  String get taskDetails => _getString('taskDetails');
  String get taskDetailPageToBeImplemented => _getString('taskDetailPageToBeImplemented');
  String get saveChanges => _getString('saveChanges');
  String get tapToChangeProfilePicture => _getString('tapToChangeProfilePicture');
  String get profilePictureChangeNotImplementedYet => _getString('profilePictureChangeNotImplementedYet');
  String get profileUpdatedSuccessfully => _getString('profileUpdatedSuccessfully');
  String get editTeam => _getString('editTeam');
  String get leaveTeam => _getString('leaveTeam');
  String get teamCodeCopiedToClipboard => _getString('teamCodeCopiedToClipboard');
  String get copyCode => _getString('copyCode');
  String get share => _getString('share');
  String get manage => _getString('manage');
  String get viewAll => _getString('viewAll');
  String get editTeamFunctionalityWillBeImplementedHere => _getString('editTeamFunctionalityWillBeImplementedHere');
  String get remove => _getString('remove');
  String get removeFromTeam => _getString('removeFromTeam');
  String get editTaskPageToBeImplemented => _getString('editTaskPageToBeImplemented');

  /// Gets localized string
  String _getString(String key) {
    final Map<String, Map<String, String>> localizedValues = {
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
        'noTasksYet': 'No Tasks Yet',
        'createYourFirstTaskToGetStarted': 'Create your first task to get started with disaster relief coordination',
        'errorLoadingTasks': 'Error Loading Tasks',
        'retry': 'Retry',
        'completed': 'Completed',
        'open': 'Open',
        'high': 'High',
        'medium': 'Medium',
        'low': 'Low',
        'assignedToLabel': 'Assigned to',
        
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
        'locationServices': 'Location Services',
        'appearance': 'Appearance',
        'theme': 'Theme',
        'data': 'Data',
        'clearCache': 'Clear Cache',
        'exportData': 'Export Data',
        'appVersionLabel': 'App Version',
        'privacyPolicy': 'Privacy Policy',
        'termsOfService': 'Terms of Service',
        'close': 'Close',
        'cancel': 'Cancel',
        'clear': 'Clear',
        'export': 'Export',
        'selectTheme': 'Select Theme',
        'system': 'System',
        'light': 'Light',
        'dark': 'Dark',
        'receiveNotificationsForNewTasksAndUpdates': 'Receive notifications for new tasks and updates',
        'allowAppToAccessYourLocationForTaskMapping': 'Allow app to access your location for task mapping',
        'clearLocallyStoredData': 'Clear locally stored data',
        'exportYourTasksAndTeamData': 'Export your tasks and team data',
        'thisWillClearAllLocallyStoredDataYouWillNeedToSignInAgain': 'This will clear all locally stored data. You will need to sign in again.',
        'thisWillExportYourTasksAndTeamDataToAFile': 'This will export your tasks and team data to a file.',
        'cacheClearedSuccessfully': 'Cache cleared successfully',
        'dataExportNotImplementedYet': 'Data export not implemented yet',
        
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
        
        // Additional UI Strings
        'signIn': 'Sign In',
        'dontHaveAnAccount': "Don't have an account? ",
        'signUp': 'Sign Up',
        'userNotAuthenticated': 'User not authenticated',
        'accountInformation': 'Account Information',
        'teamId': 'Team ID',
        'ourMission': 'Our Mission',
        'ourMissionDescription': 'Kapok is designed to help coordinate volunteers for disaster relief efforts. The app enables teams to work together efficiently during crisis situations by providing real-time task management, team coordination, and location-based services.',
        'nctdrDescription': 'The National Center for Technology and Dispute Resolution (NCTDR) is an organization that supports developing technology for conflict management. NCTDR works to create innovative solutions that help communities resolve disputes and coordinate resources during challenging times.',
        'keyFeatures': 'Key Features',
        'keyFeaturesDescription': '• Real-time task management and assignment\n• Team creation and member coordination\n• Location-based task mapping\n• Offline-first functionality for remote areas\n• Multi-language support (English & Spanish)\n• Role-based access control\n• Secure authentication and data protection',
        'technology': 'Technology',
        'technologyDescription': 'Kapok is built using modern mobile technologies including Flutter for cross-platform development, Firebase for backend services, and Mapbox for location services. The app is designed to work reliably even in areas with limited internet connectivity.',
        'contactAndSupport': 'Contact & Support',
        'contactAndSupportDescription': 'For technical support, feature requests, or general inquiries, please contact the National Center for Technology and Dispute Resolution.',
        'builtWithLove': 'Built with ❤️ for disaster relief coordination',
        'legal': 'Legal',
        'legalDescription': 'This application is developed for the National Center for Technology and Dispute Resolution. All rights reserved. The app is designed to assist in disaster relief coordination and should be used responsibly.',
        'myTeams': 'My Teams',
        'errorLoadingTeams': 'Error loading teams',
        'createNewTask': 'Create New Task',
        'createANewTaskOrLog': 'Create a new task or log',
        'enterTaskTitle': 'Enter task title',
        'enterTaskDescription': 'Enter task description',
        'enterTaskLocationOrLeaveEmptyForCurrentLocation': 'Enter task location or leave empty for current location',
        'enterUserEmailOrId': 'Enter user email or ID',
        'markAsCompleted': 'Mark as Completed',
        'checkIfThisTaskIsAlreadyCompleted': 'Check if this task is already completed',
        'save': 'Save',
        'youMustBeLoggedInToCreateTasks': 'You must be logged in to create tasks',
        'taskCreatedSuccessfully': 'Task "{taskName}" created successfully!',
        'mapPageToBeImplemented': 'Map page - To be implemented with Mapbox integration',
        'noTeamsYet': 'No Teams Yet',
        'createYourFirstTeamToGetStarted': 'Create your first team to get started with disaster relief coordination',
        'member': 'member',
        'members': 'members',
        'active': 'Active',
        'inactive': 'Inactive',
        'joinAnExistingTeamOrCreateANewOneToGetStarted': 'Join an existing team or create a new one to get started with disaster relief coordination.',
        'taskTitle': 'Task Title',
        'description': 'Description',
        'priority': 'Priority',
        'assignedToOptional': 'Assigned To (Optional)',
        'taskInformation': 'Task Information',
        'taskInformationDescription': '• Tasks will be visible to all team members\n• You can assign tasks to specific volunteers\n• Priority helps organize task urgency\n• Location coordinates will be set automatically',
        'pleaseEnterADescription': 'Please enter a description',
        'pleaseEnterALocation': 'Please enter a location',
        'fullName': 'Full Name',
        'resetPassword': 'Reset Password',
        'resetYourPassword': 'Reset Your Password',
        'resetPasswordDescription': 'Enter your email address and we\'ll send you a link to reset your password.',
        'resetPasswordEmailSentDescription': 'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.',
        'emailAddress': 'Email Address',
        'sendResetEmail': 'Send Reset Email',
        'emailSentSuccessfully': 'Email Sent Successfully!',
        'backToLogin': 'Back to Login',
        'resetPasswordHelpText': 'If you don\'t receive an email within a few minutes, check your spam folder or try again.',
        'passwordResetEmailSentTo': 'Password reset email sent to {email}',
        'byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy': 'By creating an account, you agree to our Terms of Service and Privacy Policy.',
        'createNewTeam': 'Create New Team',
        'setUpANewTeamForDisasterReliefCoordination': 'Set up a new team for disaster relief coordination',
        'enterTeamName': 'Enter team name',
        'descriptionOptional': 'Description (Optional)',
        'briefDescriptionOfTheTeamsPurpose': 'Brief description of the team\'s purpose',
        'teamLeaderBenefits': 'Team Leader Benefits',
        'teamLeaderBenefitsDescription': '• Generate team codes for members to join\n• View and manage all team tasks\n• Assign tasks to team members\n• Edit task priorities and completion status\n• Manage team members',
        'teamCreatedSuccessfullyWithCode': 'Team "{teamName}" created successfully! Team code: {teamCode}',
        'youMustBeLoggedInToCreateTeams': 'You must be logged in to create teams',
        'joinATeam': 'Join a Team',
        'enterTheTeamCodeProvidedByYourTeamLeader': 'Enter the team code provided by your team leader',
        'enter6CharacterTeamCode': 'Enter 6-character team code',
        'pleaseEnterATeamCode': 'Please enter a team code',
        'teamCodeMustBe6Characters': 'Team code must be 6 characters',
        'howToGetATeamCode': 'How to get a team code',
        'howToGetATeamCodeDescription': 'Ask your team leader to provide you with a 6-character team code. This code allows you to join their team and participate in disaster relief coordination.',
        'dontHaveATeamCodeCreateANewTeam': 'Don\'t have a team code? Create a new team',
        'youMustBeLoggedInToJoinTeams': 'You must be logged in to join teams',
        'successfullyJoinedTeam': 'Successfully joined team "{teamName}"!',
        'taskDetails': 'Task Details',
        'taskDetailPageToBeImplemented': 'Task Detail page - To be implemented',
        'saveChanges': 'Save Changes',
        'tapToChangeProfilePicture': 'Tap to change profile picture',
        'profilePictureChangeNotImplementedYet': 'Profile picture change not implemented yet',
        'profileUpdatedSuccessfully': 'Profile updated successfully!',
        'editTeam': 'Edit Team',
        'closeTeam': 'Close Team',
        'leaveTeam': 'Leave Team',
        'teamCodeCopiedToClipboard': 'Team code copied to clipboard',
        'copyCode': 'Copy Code',
        'share': 'Share',
        'manage': 'Manage',
        'viewAll': 'View All',
        'editTeamFunctionalityWillBeImplementedHere': 'Edit team functionality will be implemented here.',
        'remove': 'Remove',
        'removeFromTeam': 'Remove from Team',
        'removeMember': 'Remove Member',
        'editTask': 'Edit Task',
        'editTaskPageToBeImplemented': 'Edit Task page - To be implemented',
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
        'noTasksYet': 'Aún No Hay Tareas',
        'createYourFirstTaskToGetStarted': 'Crea tu primera tarea para comenzar con la coordinación de ayuda en desastres',
        'errorLoadingTasks': 'Error al Cargar Tareas',
        'retry': 'Reintentar',
        'completed': 'Completada',
        'open': 'Abierta',
        'high': 'Alta',
        'medium': 'Media',
        'low': 'Baja',
        'assignedToLabel': 'Asignado a',
        
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
        'locationServices': 'Servicios de Ubicación',
        'appearance': 'Apariencia',
        'theme': 'Tema',
        'data': 'Datos',
        'clearCache': 'Limpiar Caché',
        'exportData': 'Exportar Datos',
        'appVersionLabel': 'Versión de la Aplicación',
        'privacyPolicy': 'Política de Privacidad',
        'termsOfService': 'Términos de Servicio',
        'close': 'Cerrar',
        'cancel': 'Cancelar',
        'clear': 'Limpiar',
        'export': 'Exportar',
        'selectTheme': 'Seleccionar Tema',
        'system': 'Sistema',
        'light': 'Claro',
        'dark': 'Oscuro',
        'receiveNotificationsForNewTasksAndUpdates': 'Recibir notificaciones para nuevas tareas y actualizaciones',
        'allowAppToAccessYourLocationForTaskMapping': 'Permitir que la aplicación acceda a tu ubicación para mapeo de tareas',
        'clearLocallyStoredData': 'Limpiar datos almacenados localmente',
        'exportYourTasksAndTeamData': 'Exportar tus tareas y datos del equipo',
        'thisWillClearAllLocallyStoredDataYouWillNeedToSignInAgain': 'Esto limpiará todos los datos almacenados localmente. Necesitarás iniciar sesión nuevamente.',
        'thisWillExportYourTasksAndTeamDataToAFile': 'Esto exportará tus tareas y datos del equipo a un archivo.',
        'cacheClearedSuccessfully': 'Caché limpiado exitosamente',
        'dataExportNotImplementedYet': 'Exportación de datos aún no implementada',
        
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
        
        // Additional UI Strings
        'signIn': 'Iniciar Sesión',
        'dontHaveAnAccount': '¿No tienes una cuenta? ',
        'signUp': 'Registrarse',
        'userNotAuthenticated': 'Usuario no autenticado',
        'accountInformation': 'Información de la Cuenta',
        'teamId': 'ID del Equipo',
        'ourMission': 'Nuestra Misión',
        'ourMissionDescription': 'Kapok está diseñado para ayudar a coordinar voluntarios para esfuerzos de ayuda en desastres. La aplicación permite que los equipos trabajen juntos de manera eficiente durante situaciones de crisis al proporcionar gestión de tareas en tiempo real, coordinación de equipos y servicios basados en ubicación.',
        'nctdrDescription': 'El Centro Nacional de Tecnología y Resolución de Disputas (NCTDR) es una organización que apoya el desarrollo de tecnología para la gestión de conflictos. NCTDR trabaja para crear soluciones innovadoras que ayuden a las comunidades a resolver disputas y coordinar recursos durante tiempos desafiantes.',
        'keyFeatures': 'Características Clave',
        'keyFeaturesDescription': '• Gestión y asignación de tareas en tiempo real\n• Creación de equipos y coordinación de miembros\n• Mapeo de tareas basado en ubicación\n• Funcionalidad sin conexión para áreas remotas\n• Soporte multiidioma (Inglés y Español)\n• Control de acceso basado en roles\n• Autenticación segura y protección de datos',
        'technology': 'Tecnología',
        'technologyDescription': 'Kapok está construido usando tecnologías móviles modernas incluyendo Flutter para desarrollo multiplataforma, Firebase para servicios backend, y Mapbox para servicios de ubicación. La aplicación está diseñada para funcionar de manera confiable incluso en áreas con conectividad limitada a internet.',
        'contactAndSupport': 'Contacto y Soporte',
        'contactAndSupportDescription': 'Para soporte técnico, solicitudes de funciones o consultas generales, por favor contacte al Centro Nacional de Tecnología y Resolución de Disputas.',
        'builtWithLove': 'Construido con ❤️ para coordinación de ayuda en desastres',
        'legal': 'Legal',
        'legalDescription': 'Esta aplicación está desarrollada para el Centro Nacional de Tecnología y Resolución de Disputas. Todos los derechos reservados. La aplicación está diseñada para asistir en la coordinación de ayuda en desastres y debe usarse de manera responsable.',
        'myTeams': 'Mis Equipos',
        'errorLoadingTeams': 'Error al cargar equipos',
        'createNewTask': 'Crear Nueva Tarea',
        'createANewTaskOrLog': 'Crear una nueva tarea o registro',
        'enterTaskTitle': 'Ingresa el título de la tarea',
        'enterTaskDescription': 'Ingresa la descripción de la tarea',
        'enterTaskLocationOrLeaveEmptyForCurrentLocation': 'Ingresa la ubicación de la tarea o deja vacío para usar la ubicación actual',
        'enterUserEmailOrId': 'Ingresa el correo o ID del usuario',
        'markAsCompleted': 'Marcar como Completada',
        'checkIfThisTaskIsAlreadyCompleted': 'Marca si esta tarea ya está completada',
        'save': 'Guardar',
        'youMustBeLoggedInToCreateTasks': 'Debes iniciar sesión para crear tareas',
        'taskCreatedSuccessfully': '¡Tarea "{taskName}" creada exitosamente!',
        'mapPageToBeImplemented': 'Página de mapa - Por implementar con integración de Mapbox',
        'noTeamsYet': 'Aún No Hay Equipos',
        'createYourFirstTeamToGetStarted': 'Crea tu primer equipo para comenzar con la coordinación de ayuda en desastres',
        'member': 'miembro',
        'members': 'miembros',
        'active': 'Activo',
        'inactive': 'Inactivo',
        'joinAnExistingTeamOrCreateANewOneToGetStarted': 'Únete a un equipo existente o crea uno nuevo para comenzar con la coordinación de ayuda en desastres.',
        'taskTitle': 'Título de la Tarea',
        'description': 'Descripción',
        'priority': 'Prioridad',
        'assignedToOptional': 'Asignado a (Opcional)',
        'taskInformation': 'Información de la Tarea',
        'taskInformationDescription': '• Las tareas serán visibles para todos los miembros del equipo\n• Puedes asignar tareas a voluntarios específicos\n• La prioridad ayuda a organizar la urgencia de las tareas\n• Las coordenadas de ubicación se establecerán automáticamente',
        'pleaseEnterADescription': 'Por favor ingresa una descripción',
        'pleaseEnterALocation': 'Por favor ingresa una ubicación',
        'fullName': 'Nombre Completo',
        'resetPassword': 'Restablecer Contraseña',
        'resetYourPassword': 'Restablece Tu Contraseña',
        'resetPasswordDescription': 'Ingresa tu dirección de correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
        'resetPasswordEmailSentDescription': 'Hemos enviado un enlace para restablecer la contraseña a tu dirección de correo electrónico. Por favor revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
        'emailAddress': 'Dirección de Correo Electrónico',
        'sendResetEmail': 'Enviar Correo de Restablecimiento',
        'emailSentSuccessfully': '¡Correo Enviado Exitosamente!',
        'backToLogin': 'Volver al Inicio de Sesión',
        'resetPasswordHelpText': 'Si no recibes un correo en unos minutos, revisa tu carpeta de spam o intenta nuevamente.',
        'passwordResetEmailSentTo': 'Correo de restablecimiento de contraseña enviado a {email}',
        'byCreatingAnAccountYouAgreeToOurTermsOfServiceAndPrivacyPolicy': 'Al crear una cuenta, aceptas nuestros Términos de Servicio y Política de Privacidad.',
        'createNewTeam': 'Crear Nuevo Equipo',
        'setUpANewTeamForDisasterReliefCoordination': 'Configura un nuevo equipo para coordinación de ayuda en desastres',
        'enterTeamName': 'Ingresa el nombre del equipo',
        'descriptionOptional': 'Descripción (Opcional)',
        'briefDescriptionOfTheTeamsPurpose': 'Breve descripción del propósito del equipo',
        'teamLeaderBenefits': 'Beneficios del Líder de Equipo',
        'teamLeaderBenefitsDescription': '• Generar códigos de equipo para que los miembros se unan\n• Ver y gestionar todas las tareas del equipo\n• Asignar tareas a miembros del equipo\n• Editar prioridades de tareas y estado de finalización\n• Gestionar miembros del equipo',
        'teamCreatedSuccessfullyWithCode': '¡Equipo "{teamName}" creado exitosamente! Código del equipo: {teamCode}',
        'youMustBeLoggedInToCreateTeams': 'Debes iniciar sesión para crear equipos',
        'joinATeam': 'Unirse a un Equipo',
        'enterTheTeamCodeProvidedByYourTeamLeader': 'Ingresa el código del equipo proporcionado por tu líder de equipo',
        'enter6CharacterTeamCode': 'Ingresa código de equipo de 6 caracteres',
        'pleaseEnterATeamCode': 'Por favor ingresa un código de equipo',
        'teamCodeMustBe6Characters': 'El código del equipo debe tener 6 caracteres',
        'howToGetATeamCode': 'Cómo obtener un código de equipo',
        'howToGetATeamCodeDescription': 'Pide a tu líder de equipo que te proporcione un código de equipo de 6 caracteres. Este código te permite unirte a su equipo y participar en la coordinación de ayuda en desastres.',
        'dontHaveATeamCodeCreateANewTeam': '¿No tienes un código de equipo? Crea un nuevo equipo',
        'youMustBeLoggedInToJoinTeams': 'Debes iniciar sesión para unirte a equipos',
        'successfullyJoinedTeam': '¡Te uniste exitosamente al equipo "{teamName}"!',
        'taskDetails': 'Detalles de la Tarea',
        'taskDetailPageToBeImplemented': 'Página de detalles de tarea - Por implementar',
        'saveChanges': 'Guardar Cambios',
        'tapToChangeProfilePicture': 'Toca para cambiar la foto de perfil',
        'profilePictureChangeNotImplementedYet': 'Cambio de foto de perfil aún no implementado',
        'profileUpdatedSuccessfully': '¡Perfil actualizado exitosamente!',
        'editTeam': 'Editar Equipo',
        'closeTeam': 'Cerrar Equipo',
        'leaveTeam': 'Dejar Equipo',
        'teamCodeCopiedToClipboard': 'Código del equipo copiado al portapapeles',
        'copyCode': 'Copiar Código',
        'share': 'Compartir',
        'manage': 'Gestionar',
        'viewAll': 'Ver Todo',
        'editTeamFunctionalityWillBeImplementedHere': 'La funcionalidad de editar equipo se implementará aquí.',
        'remove': 'Eliminar',
        'removeFromTeam': 'Eliminar del Equipo',
        'removeMember': 'Eliminar Miembro',
        'editTask': 'Editar Tarea',
        'editTaskPageToBeImplemented': 'Página de editar tarea - Por implementar',
      },
    };

    return localizedValues[locale.languageCode]?[key] ?? key;
  }
}
