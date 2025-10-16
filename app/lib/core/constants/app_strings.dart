class AppStrings {
  // App Information
  static const String appName = 'Kapok';
  static const String appDescription = 'Disaster Relief Coordination App';
  static const String appVersion = '1.0.0';
  
  // Authentication
  static const String login = 'Login';
  static const String createAccount = 'Create Account';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String signOut = 'Sign Out';
  
  // Account Types
  static const String admin = 'Admin';
  static const String teamLeader = 'Team Leader';
  static const String teamMember = 'Team Member';
  
  // Roles
  static const String medical = 'Medical';
  static const String engineering = 'Engineering';
  static const String carpentry = 'Carpentry';
  static const String plumbing = 'Plumbing';
  static const String construction = 'Construction';
  static const String electrical = 'Electrical';
  static const String supplies = 'Supplies';
  static const String transportation = 'Transportation';
  static const String other = 'Other';
  
  // Navigation
  static const String home = 'Home';
  static const String map = 'Map';
  static const String tasks = 'Tasks';
  static const String teams = 'Teams';
  static const String profile = 'Profile';
  static const String about = 'About';
  static const String settings = 'Settings';
  
  // Tasks
  static const String createTask = 'Create Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete Task';
  static const String taskName = 'Task Name';
  static const String taskDescription = 'Task Description';
  static const String taskSeverity = 'Task Severity';
  static const String taskCompleted = 'Task Completed';
  static const String assignedTo = 'Assigned To';
  static const String teamName = 'Team Name';
  static const String location = 'Location';
  static const String myTasks = 'My Tasks';
  static const String teamTasks = 'Team Tasks';
  static const String allTasks = 'All Tasks';
  
  // Task Severity Levels
  static const String severity1 = 'Low (1)';
  static const String severity2 = 'Low-Medium (2)';
  static const String severity3 = 'Medium (3)';
  static const String severity4 = 'High (4)';
  static const String severity5 = 'Critical (5)';
  
  // Teams
  static const String createTeam = 'Create Team';
  static const String joinTeam = 'Join Team';
  static const String teamCode = 'Team Code';
  static const String generateCode = 'Generate Code';
  static const String teamMembers = 'Team Members';
  static const String removeMember = 'Remove Member';
  static const String closeTeam = 'Close Team';
  
  // Map
  static const String mapView = 'Map View';
  static const String listView = 'List View';
  static const String tapToCreateTask = 'Tap to create task';
  static const String currentLocation = 'Current Location';
  static const String searchLocation = 'Search Location';
  
  // Profile
  static const String editProfile = 'Edit Profile';
  static const String changeName = 'Change Name';
  static const String changeRole = 'Change Role';
  static const String accountType = 'Account Type';
  static const String role = 'Role';
  
  // About
  static const String aboutKapok = 'About Kapok';
  static const String aboutNCTDR = 'About NCTDR';
  static const String nationalCenterForTechnologyAndDisputeResolution = 
      'National Center for Technology and Dispute Resolution';
  static const String disasterReliefCoordination = 
      'Disaster Relief Coordination';
  
  // Settings
  static const String language = 'Language';
  static const String english = 'English';
  static const String spanish = 'Español';
  static const String notifications = 'Notifications';
  static const String offlineMode = 'Offline Mode';
  static const String syncData = 'Sync Data';
  
  // Status Messages
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String syncing = 'Syncing...';
  static const String offline = 'Offline';
  static const String online = 'Online';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  
  // Validation Messages
  static const String fieldRequired = 'This field is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String teamCodeInvalid = 'Please enter a valid team code';
  
  // Confirmation Messages
  static const String confirmDelete = 'Are you sure you want to delete this item?';
  static const String confirmSignOut = 'Are you sure you want to sign out?';
  static const String confirmCloseTeam = 'Are you sure you want to close this team?';
  static const String confirmRemoveMember = 'Are you sure you want to remove this member?';
  
  // Success Messages
  static const String taskCreated = 'Task created successfully';
  static const String taskUpdated = 'Task updated successfully';
  static const String taskDeleted = 'Task deleted successfully';
  static const String teamCreated = 'Team created successfully';
  static const String teamJoined = 'Successfully joined team';
  static const String profileUpdated = 'Profile updated successfully';
  static const String dataSynced = 'Data synced successfully';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication error. Please try again.';
  static const String permissionDenied = 'Permission denied';
  static const String locationPermissionDenied = 'Location permission denied';
  static const String teamCodeNotFound = 'Team code not found';
  static const String teamAlreadyJoined = 'You are already a member of this team';
  static const String taskNotFound = 'Task not found';
  static const String teamNotFound = 'Team not found';
  static const String userNotFound = 'User not found';
  
  // Private constructor to prevent instantiation
  AppStrings._();
}

