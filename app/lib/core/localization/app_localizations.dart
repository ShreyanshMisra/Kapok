import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../enums/task_category.dart';
import '../enums/task_priority.dart';
import '../enums/task_status.dart';
import '../enums/user_role.dart';

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
  String get assignedToNone => _getString('assignedToNone');
  String get pending => _getString('pending');
  String get overdue => _getString('overdue');
  String get dueDate => _getString('dueDate');
  String get selectDueDate => _getString('selectDueDate');
  String get clearDueDate => _getString('clearDueDate');
  String get overdueOnly => _getString('overdueOnly');

  // Task Filtering
  String get searchTasks => _getString('searchTasks');
  String get allStatuses => _getString('allStatuses');
  String get allPriorities => _getString('allPriorities');
  String get unassignedTasks => _getString('unassignedTasks');
  String get deletedUser => _getString('deletedUser');
  String get clearFilters => _getString('clearFilters');
  String get filterByStatus => _getString('filterByStatus');
  String get filterByPriority => _getString('filterByPriority');
  String get filterByAssignment => _getString('filterByAssignment');
  String get noTasksMatchFilters => _getString('noTasksMatchFilters');
  String get tryAdjustingFilters => _getString('tryAdjustingFilters');

  // Task Category
  String get taskCategory => _getString('taskCategory');
  String get allCategories => _getString('allCategories');
  String get filterByCategory => _getString('filterByCategory');
  String get category => _getString('category');

  // Date Filter
  String get filterByDate => _getString('filterByDate');
  String get allDates => _getString('allDates');
  String get pastDay => _getString('pastDay');
  String get pastWeek => _getString('pastWeek');
  String get customDateRange => _getString('customDateRange');
  String get selectDateRange => _getString('selectDateRange');

  // Validation errors
  String get validationEmailRequired => _getString('validationEmailRequired');
  String get validationEmailInvalid => _getString('validationEmailInvalid');
  String get validationPasswordRequired => _getString('validationPasswordRequired');
  String get validationPasswordTooShort => _getString('validationPasswordTooShort');
  String get validationPasswordsNoMatch => _getString('validationPasswordsNoMatch');
  String get validationNameRequired => _getString('validationNameRequired');
  String get validationNameTooShort => _getString('validationNameTooShort');
  String get validationNameTooLong => _getString('validationNameTooLong');
  String get validationTeamCodeRequired => _getString('validationTeamCodeRequired');
  String get validationTeamCodeTooShort => _getString('validationTeamCodeTooShort');
  String get validationTeamCodeTooLong => _getString('validationTeamCodeTooLong');
  String get validationTeamCodeAlphanumeric => _getString('validationTeamCodeAlphanumeric');
  String get validationTeamNameRequired => _getString('validationTeamNameRequired');
  String get validationTeamNameTooShort => _getString('validationTeamNameTooShort');
  String get validationTeamNameTooLong => _getString('validationTeamNameTooLong');
  String get validationTaskNameRequired => _getString('validationTaskNameRequired');
  String get validationTaskNameTooShort => _getString('validationTaskNameTooShort');
  String get validationTaskNameTooLong => _getString('validationTaskNameTooLong');
  String get validationTaskDescTooLong => _getString('validationTaskDescTooLong');
  String get validationFieldRequired => _getString('validationFieldRequired');
  String get confirmPasswordLabel => _getString('confirmPasswordLabel');

  // Priority Stars
  String get inProgress => _getString('inProgress');
  String get oneStar => _getString('oneStar');
  String get twoStars => _getString('twoStars');
  String get threeStars => _getString('threeStars');

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
  /// Permission level: admin, team leader, team member (UserModel.userRole).
  String get role => _getString('role');
  /// Specialty: medical, engineering, carpentry... (UserModel.role).
  String get profession => _getString('profession');
  String get changeProfession => _getString('changeProfession');
  String changeProfessionFor(String name) =>
      _getString('changeProfessionFor').replaceAll('{name}', name);
  String professionChangedTo(String name, String profession) =>
      _getString('professionChangedTo')
          .replaceAll('{name}', name)
          .replaceAll('{profession}', profession);

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
  String get continueText => _getString('continueText');
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

  // Offline & Sync
  String get offlineBanner => _getString('offlineBanner');
  String get syncPending => _getString('syncPending');
  String get syncError => _getString('syncError');
  String get lastSynced => _getString('lastSynced');

  // Status Workflow
  String get statusHistory => _getString('statusHistory');
  String get timeInStatus => _getString('timeInStatus');
  String get statusChanged => _getString('statusChanged');
  String get invalidStatusTransition => _getString('invalidStatusTransition');

  // Role Management
  String get changeSpecialtyRole => _getString('changeSpecialtyRole');
  String get roleSaved => _getString('roleSaved');
  String get selectRole => _getString('selectRole');

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

  // Terms of Service
  String get viewTermsOfService => _getString('viewTermsOfService');
  String get iAgree => _getString('iAgree');
  String get pleaseReadAndAgreeToTheFollowingTerms => _getString('pleaseReadAndAgreeToTheFollowingTerms');
  String get iHaveReadAndAgreeToTheTermsOfService => _getString('iHaveReadAndAgreeToTheTermsOfService');
  String get pleaseAgreeToTheTermsOfServiceToContinue => _getString('pleaseAgreeToTheTermsOfServiceToContinue');
  String get termsOfServiceAccepted => _getString('termsOfServiceAccepted');

  // Data Export
  String get exportSuccessful => _getString('exportSuccessful');
  String get dataExportedSuccessfully => _getString('dataExportedSuccessfully');
  String get wouldYouLikeToShareTheFile => _getString('wouldYouLikeToShareTheFile');
  String get notNow => _getString('notNow');
  String get exportFailed => _getString('exportFailed');
  String get unsyncedChangesTitle => _getString('unsyncedChangesTitle');
  String get signOutAnyway => _getString('signOutAnyway');
  String unsyncedChangesMessage(int count) =>
      _getString('unsyncedChangesMessage').replaceAll('{count}', count.toString());
  String cachedLocallyKB(int kb) =>
      _getString('cachedLocallyKB').replaceAll('{kb}', kb.toString());
  String exportedItemsCount(int tasks, int teams) =>
      _getString('exportedItemsCount')
          .replaceAll('{tasks}', tasks.toString())
          .replaceAll('{teams}', teams.toString());

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
  String get userId => _getString('userId');
  String get ourMission => _getString('ourMission');
  String get ourMissionDescription => _getString('ourMissionDescription');
  String get nctdrDescription => _getString('nctdrDescription');
  String get aFairResolutionLLC => _getString('aFairResolutionLLC');
  String get aFairResolutionLLCDescription => _getString('aFairResolutionLLCDescription');
  String get kapokIcon => _getString('kapokIcon');
  String get kapokIconDescription => _getString('kapokIconDescription');
  String get diggingDeeperTechRoots => _getString('diggingDeeperTechRoots');
  String get diggingDeeperTechRootsDescription => _getString('diggingDeeperTechRootsDescription');
  String get keyFeatures => _getString('keyFeatures');
  String get keyFeaturesDescription => _getString('keyFeaturesDescription');
  String get technology => _getString('technology');
  String get technologyDescription => _getString('technologyDescription');
  String get contactAndSupport => _getString('contactAndSupport');
  String get contactAndSupportDescription => _getString('contactAndSupportDescription');
  String get builtWithLove => _getString('builtWithLove');
  String get legal => _getString('legal');
  String get legalDescription => _getString('legalDescription');
  String get acknowledgements => _getString('acknowledgements');
  String get acknowledgementsSubtitle => _getString('acknowledgementsSubtitle');
  String get acknowledgementsIntro => _getString('acknowledgementsIntro');
  String get acknowledgementsProjectLeaders => _getString('acknowledgementsProjectLeaders');
  String get acknowledgementsProjectLeadersNames => _getString('acknowledgementsProjectLeadersNames');
  String get acknowledgementsInspiration => _getString('acknowledgementsInspiration');
  String get acknowledgementsInspirationNames => _getString('acknowledgementsInspirationNames');
  String get acknowledgementsThankYou => _getString('acknowledgementsThankYou');
  String get acknowledgementsThankYouNames => _getString('acknowledgementsThankYouNames');
  String get acknowledgementsThanksAlsoTo => _getString('acknowledgementsThanksAlsoTo');
  String get acknowledgementsThanksAlsoToNames => _getString('acknowledgementsThanksAlsoToNames');
  String get acknowledgementsClosing => _getString('acknowledgementsClosing');
  String get doNotEnterPersonalNamesNote => _getString('doNotEnterPersonalNamesNote');
  String get lastUpdated => _getString('lastUpdated');
  String get legalDraftNotice => _getString('legalDraftNotice');
  String get deleteAccount => _getString('deleteAccount');
  String get deleteAccountWarningTitle => _getString('deleteAccountWarningTitle');
  String get deleteAccountWarningBody => _getString('deleteAccountWarningBody');
  String get deleteAccountConfirmPrompt => _getString('deleteAccountConfirmPrompt');
  String get deleteAccountConfirmWord => _getString('deleteAccountConfirmWord');
  String get deleteAccountPasswordPrompt => _getString('deleteAccountPasswordPrompt');
  String get deleteAccountTransferLeadershipFirst => _getString('deleteAccountTransferLeadershipFirst');
  String get deleteAccountSuccess => _getString('deleteAccountSuccess');
  String get deleteAccountFailure => _getString('deleteAccountFailure');
  String get accountRoleSwitchSubtitle => _getString('accountRoleSwitchSubtitle');
  String get changeRoleTitle => _getString('changeRoleTitle');
  String get changeRoleToLeaderBody => _getString('changeRoleToLeaderBody');
  String get changeRoleToMemberBody => _getString('changeRoleToMemberBody');
  String get changeRoleConfirm => _getString('changeRoleConfirm');
  String roleChangedTo(String role) =>
      _getString('roleChangedTo').replaceAll('{role}', role);
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
  String get openTask => _getString('openTask');
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
  String get makeTeamLeader => _getString('makeTeamLeader');
  String get transferLeadership => _getString('transferLeadership');
  String get confirmTransferLeadership => _getString('confirmTransferLeadership');
  String get transferLeadershipSuccess => _getString('transferLeadershipSuccess');
  String get eligibleForLeadershipTransfer => _getString('eligibleForLeadershipTransfer');
  /// Shown when at least one member can receive leadership (Team Leader account).
  String get transferLeadershipDiscoverHintEligible =>
      _getString('transferLeadershipDiscoverHintEligible');
  /// Shown when no member has the Team Leader account type — explains why UI is limited.
  String get transferLeadershipNoEligibleExplanation =>
      _getString('transferLeadershipNoEligibleExplanation');
  /// Subtitle on a member row who cannot receive leadership.
  String get transferLeadershipMemberNotEligibleSubtitle =>
      _getString('transferLeadershipMemberNotEligibleSubtitle');
  String get editTaskPageToBeImplemented => _getString('editTaskPageToBeImplemented');

  // Admin Permissions Page
  String get administratorPermissions => _getString('administratorPermissions');
  String get permissionsPageDescription => _getString('permissionsPageDescription');
  String get action => _getString('action');
  String get whoCanPerform => _getString('whoCanPerform');
  String get viewTeam => _getString('viewTeam');
  String get deleteTeam => _getString('deleteTeam');
  String get viewAllTeams => _getString('viewAllTeams');
  String get anyTeamMember => _getString('anyTeamMember');
  String get teamLeaderOnly => _getString('teamLeaderOnly');
  String get anyMemberExceptLeader => _getString('anyMemberExceptLeader');
  String get adminOnly => _getString('adminOnly');
  String get adminFeaturesPlannedNote => _getString('adminFeaturesPlannedNote');

  // Profile Permissions Table
  String get permissions => _getString('permissions');
  String get editOwnTasks => _getString('editOwnTasks');
  String get editAllTasks => _getString('editAllTasks');
  String get yourRole => _getString('yourRole');

  /// Gets localized string

  // Added for the alpha-feedback localization pass
  String get statusLabel => _getString('statusLabel');
  String get titleLabel => _getString('titleLabel');
  String get all => _getString('all');
  String get apply => _getString('apply');
  String get unassigned => _getString('unassigned');
  String get ok => _getString('ok');
  String get next => _getString('next');
  String get skip => _getString('skip');
  String get getStarted => _getString('getStarted');
  String get help => _getString('help');
  String get edit => _getString('edit');
  String get delete => _getString('delete');
  String get dismiss => _getString('dismiss');
  String get created => _getString('created');
  String coordinatesValue(String coords) => _getString('coordinatesValue').replaceAll('{coords}', coords);
  String get genericError => _getString('genericError');
  String get highPriority => _getString('highPriority');
  String get mediumPriority => _getString('mediumPriority');
  String get lowPriority => _getString('lowPriority');
  String get synced => _getString('synced');
  String pendingCount(String count) => _getString('pendingCount').replaceAll('{count}', count);
  String get pageNotFound => _getString('pageNotFound');
  String get pageNotFoundDescription => _getString('pageNotFoundDescription');
  String get goHome => _getString('goHome');
  String get chooseYourRole => _getString('chooseYourRole');
  String get selectYourRoleToGetStarted => _getString('selectYourRoleToGetStarted');
  String get teamLeaderRoleDescription => _getString('teamLeaderRoleDescription');
  String get teamMemberRoleDescription => _getString('teamMemberRoleDescription');
  String get adminRoleDescription => _getString('adminRoleDescription');
  String get mustBeLoggedInToSelectRole => _getString('mustBeLoggedInToSelectRole');
  String get noSignedInUser => _getString('noSignedInUser');
  String get selectRoleFailed => _getString('selectRoleFailed');
  String get mapsStoredOffline => _getString('mapsStoredOffline');
  String get noCachedRegions => _getString('noCachedRegions');
  String get downloadRegionFromMapPage => _getString('downloadRegionFromMapPage');
  String get cachedMapsExplanation => _getString('cachedMapsExplanation');
  String get latestRegion => _getString('latestRegion');
  String allSavedRegions(String count) => _getString('allSavedRegions').replaceAll('{count}', count);
  String downloadedOn(String date) => _getString('downloadedOn').replaceAll('{date}', date);
  String tilesProgress(String done, String total) => _getString('tilesProgress').replaceAll('{done}', done).replaceAll('{total}', total);
  String get regionCenter => _getString('regionCenter');
  String get boundingBox => _getString('boundingBox');
  String get zoomRange => _getString('zoomRange');
  String get tiles => _getString('tiles');
  String cachedRegionPreview(String coords) => _getString('cachedRegionPreview').replaceAll('{coords}', coords);
  String get loadRegionsFailed => _getString('loadRegionsFailed');
  String get couldNotGetYourLocation => _getString('couldNotGetYourLocation');
  String get viewOfflineMaps => _getString('viewOfflineMaps');
  String get mapLoadFailed => _getString('mapLoadFailed');
  String get loadingMapForYourLocation => _getString('loadingMapForYourLocation');
  String get mapWaitingForRegion => _getString('mapWaitingForRegion');
  String get refreshOfflineRegion => _getString('refreshOfflineRegion');
  String get filterMarkers => _getString('filterMarkers');
  String get filterMapMarkers => _getString('filterMapMarkers');
  String get onboardingWelcomeTitle => _getString('onboardingWelcomeTitle');
  String get onboardingWelcomeBody => _getString('onboardingWelcomeBody');
  String get onboardingOfflineTitle => _getString('onboardingOfflineTitle');
  String get onboardingOfflineBody => _getString('onboardingOfflineBody');
  String get onboardingTeamsTitle => _getString('onboardingTeamsTitle');
  String get onboardingTeamsBody => _getString('onboardingTeamsBody');
  String get onboardingTasksTitle => _getString('onboardingTasksTitle');
  String get onboardingTasksBody => _getString('onboardingTasksBody');
  String get dataMayBeOutdated => _getString('dataMayBeOutdated');
  String get anyDate => _getString('anyDate');
  String get filterByDateCreated => _getString('filterByDateCreated');
  String get customRange => _getString('customRange');
  String timeInStatusShort(String time) => _getString('timeInStatusShort').replaceAll('{time}', time);
  String get onlyLeadersCanCreateTeams => _getString('onlyLeadersCanCreateTeams');
  String get teamCreatedTitle => _getString('teamCreatedTitle');
  String teamNameValue(String name) => _getString('teamNameValue').replaceAll('{name}', name);
  String get shareCodeWithYourTeamMembers => _getString('shareCodeWithYourTeamMembers');
  String get teamUpdatedSuccessfully => _getString('teamUpdatedSuccessfully');
  String get adminsHaveAccessToAllTeams => _getString('adminsHaveAccessToAllTeams');
  String clearCacheConfirmBody(String size) => _getString('clearCacheConfirmBody').replaceAll('{size}', size);
  String get clearCacheFailed => _getString('clearCacheFailed');
  String get deleteTaskConfirm => _getString('deleteTaskConfirm');
  String get helpEditTaskTip => _getString('helpEditTaskTip');
  String get helpShareTaskTip => _getString('helpShareTaskTip');
  String get helpDeleteTaskTip => _getString('helpDeleteTaskTip');
  String get completing => _getString('completing');
  String get helpCompletingTaskTip => _getString('helpCompletingTaskTip');
  String get shareTask => _getString('shareTask');
  String get pleaseEnterATitle => _getString('pleaseEnterATitle');
  String timeInStatusNamed(String status) => _getString('timeInStatusNamed').replaceAll('{status}', status);
  String get unknownDate => _getString('unknownDate');
  String get locationServicesDisabled => _getString('locationServicesDisabled');
  String get locationPermissionDeniedPermanently => _getString('locationPermissionDeniedPermanently');
  String get invalidCoordinatesReceived => _getString('invalidCoordinatesReceived');
  String get couldNotGetCurrentLocation => _getString('couldNotGetCurrentLocation');
  String usingDefaultLocation(String reason) => _getString('usingDefaultLocation').replaceAll('{reason}', reason);
  String locationSet(String location) => _getString('locationSet').replaceAll('{location}', location);
  String get enterAddressOrSelectOnMap => _getString('enterAddressOrSelectOnMap');
  String get addressNotFound => _getString('addressNotFound');
  String get helpTaskNameTitle => _getString('helpTaskNameTitle');
  String get helpTaskNameTip => _getString('helpTaskNameTip');
  String get helpPriorityTip => _getString('helpPriorityTip');
  String get helpLocationTip => _getString('helpLocationTip');
  String get assignment => _getString('assignment');
  String get helpAssignmentTip => _getString('helpAssignmentTip');
  String taskCreatedNamed(String title) => _getString('taskCreatedNamed').replaceAll('{title}', title);
  String get fetchingCurrentLocation => _getString('fetchingCurrentLocation');
  String get tapMapToSelectLocation => _getString('tapMapToSelectLocation');
  String get pleaseEnterATaskTitle => _getString('pleaseEnterATaskTitle');
  String get titleTooLong => _getString('titleTooLong');
  String get enterTaskDescriptionOptional => _getString('enterTaskDescriptionOptional');
  String get descriptionTooLong => _getString('descriptionTooLong');
  String get addressOrCoordinates => _getString('addressOrCoordinates');
  String get searchAddress => _getString('searchAddress');
  String get teamRequired => _getString('teamRequired');
  String get selectATeam => _getString('selectATeam');
  String get pleaseSelectATeam => _getString('pleaseSelectATeam');
  String get selectTeamFirstToAssign => _getString('selectTeamFirstToAssign');
  String get selectATeamMember => _getString('selectATeamMember');
  String get selectLocationOnMapOrAddress => _getString('selectLocationOnMapOrAddress');
  String get teamDeletedSuccessfully => _getString('teamDeletedSuccessfully');
  String get shareThisCodeWithTeamMembers => _getString('shareThisCodeWithTeamMembers');
  String joinMyTeamMessage(String code) => _getString('joinMyTeamMessage').replaceAll('{code}', code);
  String get noMembersFound => _getString('noMembersFound');
  String get loadMembersFailed => _getString('loadMembersFailed');
  String get leadsThisTeam => _getString('leadsThisTeam');
  String assignedTasksCount(String count) => _getString('assignedTasksCount').replaceAll('{count}', count);
  String get noAssignedTasks => _getString('noAssignedTasks');
  String get noTasksYetCreateOne => _getString('noTasksYetCreateOne');
  String get loadTasksFailed => _getString('loadTasksFailed');
  String memberWillBeRemovedFrom(String name, String team) => _getString('memberWillBeRemovedFrom').replaceAll('{name}', name).replaceAll('{team}', team);
  String memberRemovedFromTeam(String name) => _getString('memberRemovedFromTeam').replaceAll('{name}', name);
  String get deleteTeamConfirm => _getString('deleteTeamConfirm');
  String get deletingTeam => _getString('deletingTeam');
  String leaveTeamConfirm(String team) => _getString('leaveTeamConfirm').replaceAll('{team}', team);
  String youHaveLeftTeam(String team) => _getString('youHaveLeftTeam').replaceAll('{team}', team);


  // ---- Display names for stored values ----
  // Enum displayName and stored profession strings are English; use these
  // for anything shown on screen.

  String taskStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return pending;
      case TaskStatus.inProgress:
        return inProgress;
      case TaskStatus.completed:
        return completed;
    }
  }

  String taskPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return low;
      case TaskPriority.medium:
        return medium;
      case TaskPriority.high:
        return high;
    }
  }

  String taskCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.medical:
        return medical;
      case TaskCategory.engineering:
        return engineering;
      case TaskCategory.carpentry:
        return carpentry;
      case TaskCategory.plumbing:
        return plumbing;
      case TaskCategory.construction:
        return construction;
      case TaskCategory.electrical:
        return electrical;
      case TaskCategory.supplies:
        return supplies;
      case TaskCategory.transportation:
        return transportation;
      case TaskCategory.other:
        return other;
    }
  }

  String userRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return admin;
      case UserRole.teamLeader:
        return teamLeader;
      case UserRole.teamMember:
        return teamMember;
    }
  }

  /// Localized label for a profession stored in users/{uid}.role
  /// ("Medical", "Engineering", ...). Unknown values are shown as stored.
  String professionName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'medical':
        return medical;
      case 'engineering':
        return engineering;
      case 'carpentry':
        return carpentry;
      case 'plumbing':
        return plumbing;
      case 'construction':
        return construction;
      case 'electrical':
        return electrical;
      case 'supplies':
        return supplies;
      case 'transportation':
        return transportation;
      case 'other':
        return other;
      default:
        return value;
    }
  }

  String _getString(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      'en': {
        // App Information
        'appName': 'Kapok',
        'appDescription': 'Disaster Response Coordination App',
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
        'createYourFirstTaskToGetStarted': 'Create your first task to get started with disaster response coordination',
        'errorLoadingTasks': 'Error Loading Tasks',
        'retry': 'Retry',
        'completed': 'Completed',
        'open': 'Open',
        'high': 'High',
        'medium': 'Medium',
        'low': 'Low',
        'assignedToLabel': 'Assigned to',
        'assignedToNone': 'Assigned to none',
        'pending': 'Pending',
        'overdue': 'Overdue',
        'dueDate': 'Due Date',
        'selectDueDate': 'Select due date (optional)',
        'clearDueDate': 'Clear due date',
        'overdueOnly': 'Overdue only',

        // Task Filtering
        'searchTasks': 'Search tasks...',
        'allStatuses': 'All Statuses',
        'allPriorities': 'All Priorities',
        'unassignedTasks': 'Unassigned',
        'deletedUser': 'Deleted user',
        'clearFilters': 'Clear Filters',
        'filterByStatus': 'Filter by Status',
        'filterByPriority': 'Filter by Priority',
        'filterByAssignment': 'Filter by Assignment',
        'noTasksMatchFilters': 'No Tasks Match Filters',
        'tryAdjustingFilters': 'Try adjusting your filters to see more results',

        // Task Category
        'taskCategory': 'Task Category',
        'allCategories': 'All Categories',
        'filterByCategory': 'Filter by Category',
        'category': 'Category',

        // Date Filter
        'filterByDate': 'Filter by Date',
        'allDates': 'All Dates',
        'pastDay': 'Past Day',
        'pastWeek': 'Past Week',
        'customDateRange': 'Custom Date Range',
        'selectDateRange': 'Select Date Range',

        // Validation errors (EN)
        'validationEmailRequired': 'Email is required',
        'validationEmailInvalid': 'Please enter a valid email address',
        'validationPasswordRequired': 'Password is required',
        'validationPasswordTooShort': 'Password must be at least 6 characters',
        'validationPasswordsNoMatch': 'Passwords do not match',
        'validationNameRequired': 'Name is required',
        'validationNameTooShort': 'Name must be at least 2 characters',
        'validationNameTooLong': 'Name must be less than 50 characters',
        'validationTeamCodeRequired': 'Team code is required',
        'validationTeamCodeTooShort': 'Team code must be at least 4 characters',
        'validationTeamCodeTooLong': 'Team code must be less than 20 characters',
        'validationTeamCodeAlphanumeric': 'Team code can only contain letters and numbers',
        'validationTeamNameRequired': 'Team name is required',
        'validationTeamNameTooShort': 'Team name must be at least 3 characters',
        'validationTeamNameTooLong': 'Team name must be less than 50 characters',
        'validationTaskNameRequired': 'Task name is required',
        'validationTaskNameTooShort': 'Task name must be at least 3 characters',
        'validationTaskNameTooLong': 'Task name must be less than 100 characters',
        'validationTaskDescTooLong': 'Description must be less than 500 characters',
        'validationFieldRequired': 'This field is required',
        'confirmPasswordLabel': 'Confirm Password',

        // Priority Stars
        'oneStar': '1 Star',
        'twoStars': '2 Stars',
        'threeStars': '3 Stars',
        'inProgress': 'In Progress',

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
        'role': 'Role',
        'profession': 'Profession',
        'changeProfession': 'Change profession',
        'changeProfessionFor': 'Change profession for {name}',
        'professionChangedTo': "{name}'s profession changed to {profession}",
        
        // About
        'aboutKapok': 'About Kapok',
        'aboutNCTDR': 'About NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'National Center for Technology and Dispute Resolution',
        'disasterReliefCoordination': 'Disaster Response Coordination',
        
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
        'cachedLocallyKB': '~{kb} KB cached locally',
        'unsyncedChangesTitle': 'Unsynced changes',
        'unsyncedChangesMessage': 'You have {count} change(s) that haven\'t been uploaded yet. Signing out will permanently discard them. To keep them, connect to the internet and wait for syncing to finish before signing out.',
        'signOutAnyway': 'Sign out anyway',
        'exportData': 'Export Data',
        'appVersionLabel': 'App Version',
        'privacyPolicy': 'Privacy Policy',
        'termsOfService': 'Terms of Service',
        'close': 'Close',
        'continueText': 'Continue',
        'cancel': 'Cancel',
        'clear': 'Clear',
        'export': 'Export',
        'selectTheme': 'Select Theme',
        'system': 'Default',
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
        
        // Offline & Sync
        'offlineBanner': 'You\'re offline — changes will sync when connected',
        'syncPending': 'pending',
        'syncError': 'Sync error',
        'lastSynced': 'Last synced',

        // Status Workflow
        'statusHistory': 'Status History',
        'timeInStatus': 'Time in status',
        'statusChanged': 'Status changed',
        'invalidStatusTransition': 'Invalid status transition',

        // Role Management
        'changeSpecialtyRole': 'Change Specialty Role',
        'roleSaved': 'Role saved successfully',
        'selectRole': 'Select Role',

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

        // Terms of Service
        'viewTermsOfService': 'View Terms of Service',
        'iAgree': 'I Agree',
        'pleaseReadAndAgreeToTheFollowingTerms': 'Please read and agree to the following terms:',
        'iHaveReadAndAgreeToTheTermsOfService': 'I have read and agree to the Terms of Service',
        'pleaseAgreeToTheTermsOfServiceToContinue': 'Please agree to the Terms of Service to continue.',
        'termsOfServiceAccepted': 'Terms of Service accepted',

        // Data Export
        'exportSuccessful': 'Export Successful',
        'dataExportedSuccessfully': 'Your disaster response data has been exported successfully.',
        'exportedItemsCount': 'Exported {tasks} tasks and {teams} teams',
        'wouldYouLikeToShareTheFile': 'Would you like to share the export file now?',
        'notNow': 'Not Now',
        'exportFailed': 'Export Failed',

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
        'userId': 'User ID',
        'ourMission': 'Our Mission',
        'ourMissionDescription': 'Kapok is designed to help coordinate volunteers for disaster response efforts. The app enables teams to work together efficiently during crisis situations by providing real-time task management, team coordination, and location-based services.',
        'nctdrDescription': 'The National Center for Technology and Dispute Resolution (NCTDR) is an organization that supports developing technology for conflict management. NCTDR works to create innovative solutions that help communities resolve disputes and coordinate resources during challenging times.',
        'keyFeatures': 'Key Features',
        'keyFeaturesDescription': '• Real-time task management and assignment\n• Team creation and member coordination\n• Location-based task mapping\n• Offline-first functionality for remote areas\n• Bilingual support (English and Spanish)\n• Role-based access control\n• Secure authentication and encrypted data transfer',
        'technology': 'Technology',
        'technologyDescription': 'Kapok is built using mobile technologies including Flutter for cross-platform development, Firebase for backend services, and Mapbox for location services. The app is designed to work even in areas with limited Internet connectivity.',
        'contactAndSupport': 'Contact & Support',
        'contactAndSupportDescription': 'For technical support, feature requests, or general inquiries, please contact A Fair Resolution, LLC.',
        'builtWithLove': 'Built with ❤️ for disaster response coordination.',
        'legal': 'Legal',
        'legalDescription': '© 2026 A Fair Resolution, LLC. All rights reserved. Kapok is owned by A Fair Resolution, LLC. Kapok is designed to assist in disaster response coordination. Users are responsible for their data and usage of the app and should comply with all applicable laws.',
        'acknowledgements': 'Acknowledgements',
        'acknowledgementsSubtitle': 'The people who made Kapok possible',
        'acknowledgementsIntro': 'Thank you to all who inspired and assisted in the creation of Kapok: multidisciplinary and multilingual volunteers from many nations: software developers, RNs, online dispute resolution experts, attorneys, and hurricane survivor family members. Inspired by the dedication and resilience of first responders and survivors, we seek to harness technology to assist in disaster prevention and response.',
        'acknowledgementsProjectLeaders': 'Project Leaders',
        'acknowledgementsProjectLeadersNames': 'Leah Wing\nNatasha Sustache',
        'acknowledgementsInspiration': 'Inspiration',
        'acknowledgementsInspirationNames': 'Natasha S.\nJustin J.\nRuth S.\nRoxanna G.\nKerry G.\nEleanor G.\nMelina A.\nOther disaster medical responders',
        'acknowledgementsThankYou': 'Thank you',
        'acknowledgementsThankYouNames': 'Brian R.\nSiddartha S.\nNishant A.\nAparimit C.\nShreyansh M.\nBrian N.\nFuming Z.\nLimbani C.\nAdhiraj C.\nAdvait G.',
        'acknowledgementsThanksAlsoTo': 'Thanks also to',
        'acknowledgementsThanksAlsoToNames': 'Shriya S.\nNitya V.\nJonathan Z.\nKiran B. K.\nNgoc D. N.\nDia S.\nKhushi R.\nAastha A.\nArushi A.\nKhushii S.\nEric W.\nPaul D.\nKevin L.\nYona V.-A.\nSuryam G.\nShobhit M.\nEmmet H.\nBhargavi P.\nAtharva S.\nAhmed K.\nThuy N.\nAtonbara D.-K.\nNigel P.\nBryan C.\nGaurav S.\nTejovrash A.\nMethasith R.\nYasmeen M.\nBrijesh V.\nMena I.\nLuke T.\nAndrew T.\nAlbi M.\nNihar K.\nRishi P.\nPrasad A.\nSelena L.\nPhoebe L.\nRishab M.\nKhang N.\nAnh T.\nSnigdha T.\nYusef W.\nIan D’S.\nSapna P.\nShreya M.\nSarah W.\nEzinne O.\nDarrell M.\nEmma W.\nSha B.\nKhanh T. T. D.-M.\nChristopher G.\nJose A. O.\nJanet M.\nVikki R.\nCrystal P.\nVal N.\nChris D.\nSasha R.\nAshley W.\nJessica R.\nNoe H.\nA Fair Resolution, LLC',
        'acknowledgementsClosing': '',
        'doNotEnterPersonalNamesNote': 'Do not enter any person\'s name in the task.',
        'lastUpdated': 'Last updated',
        'legalDraftNotice': 'This document is a draft pending final legal review. Placeholders in square brackets will be filled in before public release.',
        'deleteAccount': 'Delete account',
        'deleteAccountWarningTitle': 'Delete your account?',
        'deleteAccountWarningBody': 'This permanently removes your profile and signs you out. Tasks you created or were assigned to will be kept for your team but anonymized (your name is replaced with "deleted_user"). This cannot be undone.',
        'deleteAccountConfirmPrompt': 'Type DELETE to confirm',
        'deleteAccountConfirmWord': 'DELETE',
        'deleteAccountPasswordPrompt': 'Enter your password to confirm it\'s you',
        'deleteAccountTransferLeadershipFirst': 'You lead one or more active teams. Transfer leadership to another team member from the team page before deleting your account.',
        'deleteAccountSuccess': 'Your account has been deleted.',
        'deleteAccountFailure': 'Could not delete the account. Please try again.',
        'accountRoleSwitchSubtitle': 'Team leaders can create and manage teams',
        'changeRoleTitle': 'Change your role?',
        'changeRoleToLeaderBody': 'As a team leader you can create teams and manage their members and tasks. You can switch back at any time.',
        'changeRoleToMemberBody': 'As a team member you will no longer be able to create or manage teams. If you lead an active team, transfer leadership first.',
        'changeRoleConfirm': 'Change role',
        'roleChangedTo': 'Your role is now {role}.',
        'aFairResolutionLLC': 'A Fair Resolution, LLC',
        'aFairResolutionLLCDescription': 'A Fair Resolution, LLC is an organization dedicated to dispute prevention and resolution. It works to create innovative solutions that help communities prevent and resolve disputes and coordinate resources during challenging times.',
        'kapokIcon': 'Kapok Icon',
        'kapokIconDescription': 'Inspiration: The Living Tree\n\nAt the heart of the design is a majestic kapok tree, its sprawling canopy symbolizing the robust network of individuals united in a mission of disaster response. Every leaf and branch represents the vital links between team members, emphasizing collaboration, rapid response, and the collective strength that drives Kapok\'s initiative forward.',
        'diggingDeeperTechRoots': 'Digging Deeper: Tech Roots',
        'diggingDeeperTechRootsDescription': 'Beneath the tree, an intricate network of roots unfolds like a circuit board, illustrating that the foundation of Kapok\'s operation is deeply embedded in advanced technology. This creative fusion of natural form and technical precision speaks to the modern, adaptive strategies the team employs in the face of adversity. The Kapok app was made for you.',
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
        'createYourFirstTeamToGetStarted': 'Create your first team to get started with disaster response coordination',
        'member': 'member',
        'members': 'members',
        'active': 'Active',
        'inactive': 'Inactive',
        'joinAnExistingTeamOrCreateANewOneToGetStarted': 'Join an existing team or create a new one to get started with disaster response coordination.',
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
        'setUpANewTeamForDisasterReliefCoordination': 'Set up a new team for disaster response coordination',
        'enterTeamName': 'Enter team name',
        'descriptionOptional': 'Description (Optional)',
        'briefDescriptionOfTheTeamsPurpose': 'Brief description of the team\'s purpose',
        'teamLeaderBenefits': 'Team Leader Functionalities',
        'teamLeaderBenefitsDescription': '• Generate team codes for members to join\n• View and manage all team tasks\n• Assign tasks to team members\n• Edit task priorities and completion status\n• Manage team members',
        'teamCreatedSuccessfullyWithCode': 'Team "{teamName}" created successfully! Team code: {teamCode}',
        'youMustBeLoggedInToCreateTeams': 'You must be logged in to create teams',
        'joinATeam': 'Join a Team',
        'enterTheTeamCodeProvidedByYourTeamLeader': 'Enter the team code provided by your team leader',
        'enter6CharacterTeamCode': 'Enter 6-character team code',
        'pleaseEnterATeamCode': 'Please enter a team code',
        'teamCodeMustBe6Characters': 'Team code must be 6 characters',
        'howToGetATeamCode': 'How to get a team code',
        'howToGetATeamCodeDescription': 'Ask your team leader to provide you with a 6-character team code. This code allows you to join their team and participate in disaster response coordination.',
        'dontHaveATeamCodeCreateANewTeam': 'Don\'t have a team code? Create a new team',
        'youMustBeLoggedInToJoinTeams': 'You must be logged in to join teams',
        'successfullyJoinedTeam': 'Successfully joined team "{teamName}"!',
        'taskDetails': 'Task Details',
        'openTask': 'Open Task',
        'taskDetailPageToBeImplemented': 'Task Detail page - To be implemented',
        'saveChanges': 'Save Changes',
        'tapToChangeProfilePicture': 'Tap to change profile picture',
        'profilePictureChangeNotImplementedYet': 'Profile picture change not implemented yet',
        'profileUpdatedSuccessfully': 'Profile updated successfully!',
        'editTeam': 'Edit Team',
        'leaveTeam': 'Leave Team',
        'teamCodeCopiedToClipboard': 'Team code copied to clipboard',
        'copyCode': 'Copy Code',
        'share': 'Share',
        'manage': 'Manage',
        'viewAll': 'View All',
        'editTeamFunctionalityWillBeImplementedHere': 'Edit team functionality will be implemented here.',
        'remove': 'Remove',
        'removeFromTeam': 'Remove from Team',
        'makeTeamLeader': 'Make Team Leader',
        'transferLeadership': 'Transfer Leadership',
        'confirmTransferLeadership': 'Transfer leadership to this member? You will remain a member but will no longer be the leader.',
        'transferLeadershipSuccess': 'Leadership transferred successfully',
        'eligibleForLeadershipTransfer': 'This member can receive leadership (Team Leader account)',
        'transferLeadershipDiscoverHintEligible':
            'Transfer leadership: open the ⋮ menu above, or expand a member below who has a Team Leader account.',
        'transferLeadershipNoEligibleExplanation':
            'Transfer leadership only works for members who signed up with the Team Leader account type. Team Member accounts cannot become team leader yet. Invite someone who uses Team Leader, or ask a member to create a Team Leader account and rejoin.',
        'transferLeadershipMemberNotEligibleSubtitle':
            'Cannot receive leadership — Team Leader account required',
        'editTaskPageToBeImplemented': 'Edit Task page - To be implemented',

        // Admin Permissions Page
        'administratorPermissions': 'Administrator Permissions',
        'permissionsPageDescription': 'This page documents the permission model for the Kapok app. Each action is restricted to specific roles.',
        'action': 'Action',
        'whoCanPerform': 'Who Can Perform',
        'viewTeam': 'View Team',
        'deleteTeam': 'Delete Team',
        'viewAllTeams': 'View All Teams',
        'anyTeamMember': 'Any team member',
        'teamLeaderOnly': 'Team Leader only',
        'anyMemberExceptLeader': 'Any member (except leader)',
        'adminOnly': 'Admin only',
        'adminFeaturesPlannedNote': 'Note: Some admin-specific actions (such as "View All Teams" and "Delete Team") are planned but not yet fully functional in the backend.',

        // Profile Permissions Table
        'permissions': 'Permissions',
        'editOwnTasks': 'Edit Own Tasks',
        'editAllTasks': 'Edit All Tasks',
        'yourRole': 'Your Role',

        // Alpha-feedback localization pass
        'statusLabel': 'Status',
        'titleLabel': 'Title',
        'all': 'All',
        'apply': 'Apply',
        'unassigned': 'Unassigned',
        'ok': 'OK',
        'next': 'Next',
        'skip': 'Skip',
        'getStarted': 'Get Started',
        'help': 'Help',
        'edit': 'Edit',
        'delete': 'Delete',
        'dismiss': 'Dismiss',
        'created': 'Created',
        'coordinatesValue': 'Coordinates: {coords}',
        'genericError': 'Something went wrong. Please try again.',
        'highPriority': 'High Priority',
        'mediumPriority': 'Medium Priority',
        'lowPriority': 'Low Priority',
        'synced': 'Synced',
        'pendingCount': '{count} pending',
        'pageNotFound': 'Page Not Found',
        'pageNotFoundDescription': 'The page you are looking for does not exist.',
        'goHome': 'Go Home',
        'chooseYourRole': 'Choose Your Role',
        'selectYourRoleToGetStarted': 'Select your role to get started',
        'teamLeaderRoleDescription': 'Create and manage a team',
        'teamMemberRoleDescription': 'Join an existing team',
        'adminRoleDescription': 'Oversee all teams and tasks',
        'mustBeLoggedInToSelectRole': 'You must be logged in to select a role',
        'noSignedInUser': 'You\'re not signed in. Please sign in again.',
        'selectRoleFailed': 'Could not save your role. Please try again.',
        'mapsStoredOffline': 'Maps Stored Offline',
        'noCachedRegions': 'No cached regions',
        'downloadRegionFromMapPage': 'Download a region from the map page',
        'cachedMapsExplanation': 'These are your cached maps which are stored offline temporarily. They are downloaded when you zoom into a new location in Maps so that you can access this map while you are not connected to the internet. You can delete maps stored offline using Clear Cache in settings to free up storage.',
        'latestRegion': 'Latest Region',
        'allSavedRegions': 'All Saved Regions ({count})',
        'downloadedOn': 'Downloaded: {date}',
        'tilesProgress': '{done}/{total} tiles',
        'regionCenter': 'Center',
        'boundingBox': 'Bounding Box',
        'zoomRange': 'Zoom Range',
        'tiles': 'Tiles',
        'cachedRegionPreview': 'Cached Region Preview - Center: {coords}',
        'loadRegionsFailed': 'Could not load your offline maps. Please try again.',
        'couldNotGetYourLocation': 'Could not get your current location. Check that location access is allowed.',
        'viewOfflineMaps': 'View offline maps',
        'mapLoadFailed': 'Could not load the map. Please try again.',
        'loadingMapForYourLocation': 'Loading the map for your location...',
        'mapWaitingForRegion': 'The map hasn\'t loaded yet.',
        'refreshOfflineRegion': 'Refresh Offline Region',
        'filterMarkers': 'Filter markers',
        'filterMapMarkers': 'Filter Map Markers',
        'onboardingWelcomeTitle': 'Welcome to Kapok',
        'onboardingWelcomeBody': 'Coordinate disaster response efforts with your team. Manage tasks, track progress, and respond to emergencies efficiently.',
        'onboardingOfflineTitle': 'Works Completely Offline',
        'onboardingOfflineBody': 'No internet? No problem. Create tasks, manage teams, and coordinate response efforts even without connectivity. Everything syncs automatically when you reconnect.',
        'onboardingTeamsTitle': 'Team Coordination',
        'onboardingTeamsBody': 'Create teams with unique join codes. Assign roles, manage members, and keep everyone synchronized on priorities and responsibilities.',
        'onboardingTasksTitle': 'Smart Task Management',
        'onboardingTasksBody': 'Create location-based tasks with priorities and categories. Assign to team members, track status, and visualize everything on an interactive map.',
        'dataMayBeOutdated': 'Data may be outdated — last synced over 30 min ago',
        'anyDate': 'Any date',
        'filterByDateCreated': 'Filter by Date Created',
        'customRange': 'Custom range',
        'timeInStatusShort': '{time} in status',
        'onlyLeadersCanCreateTeams': 'Only team leaders and admins can create teams',
        'teamCreatedTitle': 'Team Created Successfully!',
        'teamNameValue': 'Team Name: {name}',
        'shareCodeWithYourTeamMembers': 'Share this code with your team members',
        'teamUpdatedSuccessfully': 'Team updated successfully',
        'adminsHaveAccessToAllTeams': 'Admins have access to all teams',
        'clearCacheConfirmBody': 'This will clear approximately {size} KB of locally saved data (tasks, teams, filters). Your language and theme are kept. You will need to sync again after clearing.',
        'clearCacheFailed': 'Could not clear saved data. Please try again.',
        'deleteTaskConfirm': 'Are you sure you want to delete this task? This action cannot be undone.',
        'helpEditTaskTip': 'Tap the pencil icon to edit the task name, description, priority, and more.',
        'helpShareTaskTip': 'Use the share button to send task details to others.',
        'helpDeleteTaskTip': 'Tap the trash icon to permanently delete this task.',
        'completing': 'Completing',
        'helpCompletingTaskTip': 'Change the status to "Completed" using the status dropdown and save to mark the task done.',
        'shareTask': 'Share task',
        'pleaseEnterATitle': 'Please enter a title',
        'timeInStatusNamed': 'Time in {status}',
        'unknownDate': 'Unknown date',
        'locationServicesDisabled': 'Location services are disabled',
        'locationPermissionDeniedPermanently': 'Location permission denied permanently',
        'invalidCoordinatesReceived': 'Invalid coordinates received',
        'couldNotGetCurrentLocation': 'Could not get current location',
        'usingDefaultLocation': '{reason}. Using default location.',
        'locationSet': 'Location set: {location}',
        'enterAddressOrSelectOnMap': 'Please enter an address or select a location on the map',
        'addressNotFound': 'Could not find that address. Check it and try again.',
        'helpTaskNameTitle': 'Task Name & Description',
        'helpTaskNameTip': 'Give the task a clear name (3–100 chars) and an optional description.',
        'helpPriorityTip': 'Set Low, Medium, or High priority so team members know what to tackle first.',
        'helpLocationTip': 'Tap on the map or use the location button to pin the task to a specific spot.',
        'assignment': 'Assignment',
        'helpAssignmentTip': 'Assign the task to a team member or leave it unassigned for anyone to pick up.',
        'taskCreatedNamed': 'Task "{title}" created successfully',
        'fetchingCurrentLocation': 'Fetching current location...',
        'tapMapToSelectLocation': 'Tap on the map to select a location for your task',
        'pleaseEnterATaskTitle': 'Please enter a task title',
        'titleTooLong': 'Title must be 100 characters or less',
        'enterTaskDescriptionOptional': 'Enter task description (optional)',
        'descriptionTooLong': 'Description must be 500 characters or less',
        'addressOrCoordinates': 'Address or coordinates',
        'searchAddress': 'Search address',
        'teamRequired': 'Team *',
        'selectATeam': 'Select a team',
        'pleaseSelectATeam': 'Please select a team',
        'selectTeamFirstToAssign': 'Select a team first to assign task',
        'selectATeamMember': 'Select a team member',
        'selectLocationOnMapOrAddress': 'Please select a location on the map or enter an address',
        'teamDeletedSuccessfully': 'Team deleted successfully',
        'shareThisCodeWithTeamMembers': 'Share this code with team members',
        'joinMyTeamMessage': 'Join my team on Kapok! Team code: {code}',
        'noMembersFound': 'No members found',
        'loadMembersFailed': 'Could not load team members. Please try again.',
        'leadsThisTeam': 'Leads this team',
        'assignedTasksCount': 'Assigned Tasks ({count})',
        'noAssignedTasks': 'No assigned tasks',
        'noTasksYetCreateOne': 'No tasks yet. Create one to get started!',
        'loadTasksFailed': 'Could not load tasks. Please try again.',
        'memberWillBeRemovedFrom': '{name} will be removed from {team}.',
        'memberRemovedFromTeam': '{name} removed from team',
        'deleteTeamConfirm': 'Are you sure you want to permanently delete this team? This action cannot be undone. All team members will be removed from the team.',
        'deletingTeam': 'Deleting team...',
        'leaveTeamConfirm': 'Are you sure you want to leave {team}? Any tasks assigned to you in this team will be unassigned.',
        'youHaveLeftTeam': 'You have left {team}',
      },
      'es': {
        // App Information
        'appName': 'Kapok',
        'appDescription': 'Aplicación de Coordinación de Respuesta a Desastres',
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
        'createYourFirstTaskToGetStarted': 'Crea tu primera tarea para comenzar con la coordinación de respuesta a desastres',
        'errorLoadingTasks': 'Error al Cargar Tareas',
        'retry': 'Reintentar',
        'completed': 'Completada',
        'open': 'Abierta',
        'high': 'Alta',
        'medium': 'Media',
        'low': 'Baja',
        'assignedToLabel': 'Asignado a',
        'assignedToNone': 'Asignado a nadie',
        'pending': 'Pendiente',
        'overdue': 'Vencido',
        'dueDate': 'Fecha de vencimiento',
        'selectDueDate': 'Seleccionar fecha (opcional)',
        'clearDueDate': 'Quitar fecha',
        'overdueOnly': 'Solo vencidas',

        // Task Filtering
        'searchTasks': 'Buscar tareas...',
        'allStatuses': 'Todos los Estados',
        'allPriorities': 'Todas las Prioridades',
        'unassignedTasks': 'Sin Asignar',
        'deletedUser': 'Usuario eliminado',
        'clearFilters': 'Limpiar Filtros',
        'filterByStatus': 'Filtrar por Estado',
        'filterByPriority': 'Filtrar por Prioridad',
        'filterByAssignment': 'Filtrar por Asignación',
        'noTasksMatchFilters': 'No Hay Tareas que Coincidan con los Filtros',
        'tryAdjustingFilters': 'Intenta ajustar tus filtros para ver más resultados',

        // Task Category
        'taskCategory': 'Categoría de Tarea',
        'allCategories': 'Todas las Categorías',
        'filterByCategory': 'Filtrar por Categoría',
        'category': 'Categoría',

        // Date Filter
        'filterByDate': 'Filtrar por Fecha',
        'allDates': 'Todas las Fechas',
        'pastDay': 'Último Día',
        'pastWeek': 'Última Semana',
        'customDateRange': 'Rango de Fechas Personalizado',
        'selectDateRange': 'Seleccionar Rango de Fechas',

        // Validation errors (ES)
        'validationEmailRequired': 'El correo es requerido',
        'validationEmailInvalid': 'Por favor ingrese un correo válido',
        'validationPasswordRequired': 'La contraseña es requerida',
        'validationPasswordTooShort': 'La contraseña debe tener al menos 6 caracteres',
        'validationPasswordsNoMatch': 'Las contraseñas no coinciden',
        'validationNameRequired': 'El nombre es requerido',
        'validationNameTooShort': 'El nombre debe tener al menos 2 caracteres',
        'validationNameTooLong': 'El nombre debe tener menos de 50 caracteres',
        'validationTeamCodeRequired': 'El código de equipo es requerido',
        'validationTeamCodeTooShort': 'El código debe tener al menos 4 caracteres',
        'validationTeamCodeTooLong': 'El código debe tener menos de 20 caracteres',
        'validationTeamCodeAlphanumeric': 'El código solo puede contener letras y números',
        'validationTeamNameRequired': 'El nombre del equipo es requerido',
        'validationTeamNameTooShort': 'El nombre debe tener al menos 3 caracteres',
        'validationTeamNameTooLong': 'El nombre debe tener menos de 50 caracteres',
        'validationTaskNameRequired': 'El nombre de la tarea es requerido',
        'validationTaskNameTooShort': 'El nombre debe tener al menos 3 caracteres',
        'validationTaskNameTooLong': 'El nombre debe tener menos de 100 caracteres',
        'validationTaskDescTooLong': 'La descripción debe tener menos de 500 caracteres',
        'validationFieldRequired': 'Este campo es requerido',
        'confirmPasswordLabel': 'Confirmar contraseña',

        // Priority Stars
        'oneStar': '1 Estrella',
        'twoStars': '2 Estrellas',
        'threeStars': '3 Estrellas',
        'inProgress': 'En Progreso',

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
        'role': 'Rol',
        'profession': 'Profesión',
        'changeProfession': 'Cambiar profesión',
        'changeProfessionFor': 'Cambiar profesión de {name}',
        'professionChangedTo': 'La profesión de {name} cambió a {profession}',
        
        // About
        'aboutKapok': 'Acerca de Kapok',
        'aboutNCTDR': 'Acerca de NCTDR',
        'nationalCenterForTechnologyAndDisputeResolution': 'Centro Nacional de Tecnología y Resolución de Disputas',
        'disasterReliefCoordination': 'Coordinación de Respuesta a Desastres',
        
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
        'cachedLocallyKB': '~{kb} KB en caché local',
        'unsyncedChangesTitle': 'Cambios sin sincronizar',
        'unsyncedChangesMessage': 'Tienes {count} cambio(s) que aún no se han subido. Si cierras sesión, se descartarán permanentemente. Para conservarlos, conéctate a internet y espera a que termine la sincronización antes de cerrar sesión.',
        'signOutAnyway': 'Cerrar sesión de todos modos',
        'exportData': 'Exportar Datos',
        'appVersionLabel': 'Versión de la Aplicación',
        'privacyPolicy': 'Política de Privacidad',
        'termsOfService': 'Términos de Servicio',
        'close': 'Cerrar',
        'continueText': 'Continuar',
        'cancel': 'Cancelar',
        'clear': 'Limpiar',
        'export': 'Exportar',
        'selectTheme': 'Seleccionar Tema',
        'system': 'Predeterminado',
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
        
        // Offline & Sync
        'offlineBanner': 'Sin conexión — los cambios se sincronizarán al conectarse',
        'syncPending': 'pendientes',
        'syncError': 'Error de sincronización',
        'lastSynced': 'Última sincronización',

        // Status Workflow
        'statusHistory': 'Historial de Estado',
        'timeInStatus': 'Tiempo en estado',
        'statusChanged': 'Estado cambiado',
        'invalidStatusTransition': 'Transición de estado inválida',

        // Role Management
        'changeSpecialtyRole': 'Cambiar Rol de Especialidad',
        'roleSaved': 'Rol guardado exitosamente',
        'selectRole': 'Seleccionar Rol',

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

        // Terms of Service
        'viewTermsOfService': 'Ver Términos de Servicio',
        'iAgree': 'Acepto',
        'pleaseReadAndAgreeToTheFollowingTerms': 'Por favor lee y acepta los siguientes términos:',
        'iHaveReadAndAgreeToTheTermsOfService': 'He leído y acepto los Términos de Servicio',
        'pleaseAgreeToTheTermsOfServiceToContinue': 'Por favor acepta los Términos de Servicio para continuar.',
        'termsOfServiceAccepted': 'Términos de Servicio aceptados',

        // Data Export
        'exportSuccessful': 'Exportación Exitosa',
        'dataExportedSuccessfully': 'Sus datos de respuesta a desastres se han exportado exitosamente.',
        'exportedItemsCount': '{tasks} tareas y {teams} equipos exportados',
        'wouldYouLikeToShareTheFile': '¿Desea compartir el archivo de exportación ahora?',
        'notNow': 'Ahora No',
        'exportFailed': 'Exportación Fallida',

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
        'userId': 'ID de Usuario',
        'ourMission': 'Nuestra Misión',
        'ourMissionDescription': 'Kapok está diseñado para ayudar a coordinar voluntarios para esfuerzos de respuesta a desastres. La aplicación permite que los equipos trabajen juntos de manera eficiente durante situaciones de crisis al proporcionar gestión de tareas en tiempo real, coordinación de equipos y servicios basados en ubicación.',
        'nctdrDescription': 'El Centro Nacional de Tecnología y Resolución de Disputas (NCTDR) es una organización que apoya el desarrollo de tecnología para la gestión de conflictos. NCTDR trabaja para crear soluciones innovadoras que ayuden a las comunidades a resolver disputas y coordinar recursos durante tiempos desafiantes.',
        'keyFeatures': 'Características Clave',
        'keyFeaturesDescription': '• Gestión y asignación de tareas en tiempo real\n• Creación de equipos y coordinación de miembros\n• Mapeo de tareas basado en ubicación\n• Funcionalidad sin conexión para áreas remotas\n• Soporte bilingüe (Inglés y Español)\n• Control de acceso basado en roles\n• Autenticación segura y transferencia de datos cifrada',
        'technology': 'Tecnología',
        'technologyDescription': 'Kapok está construido usando tecnologías móviles incluyendo Flutter para desarrollo multiplataforma, Firebase para servicios backend, y Mapbox para servicios de ubicación. La aplicación está diseñada para funcionar en áreas con conectividad limitada a Internet.',
        'contactAndSupport': 'Contacto y Soporte',
        'contactAndSupportDescription': 'Para soporte técnico, solicitudes de funciones o consultas generales, por favor contacte a A Fair Resolution, LLC.',
        'builtWithLove': 'Construido con ❤️ para coordinación de respuesta a desastres.',
        'legal': 'Legal',
        'legalDescription': '© 2026 A Fair Resolution, LLC. Todos los derechos reservados. Kapok es propiedad de A Fair Resolution, LLC. Kapok está diseñado para asistir en la coordinación de respuesta a desastres. Los usuarios son responsables de sus datos y uso de la aplicación y deben cumplir con todas las leyes aplicables.',
        'acknowledgements': 'Agradecimientos',
        'acknowledgementsSubtitle': 'Las personas que hicieron Kapok posible',
        'acknowledgementsIntro': 'Gracias a todos quienes inspiraron y asistieron en la creación de Kapok: voluntarios multidisciplinarios y multilingües de muchas naciones: desarrolladores de software, enfermeras, expertos en resolución de disputas en línea, abogados y familiares sobrevivientes de huracanes. Inspirados por la dedicación y resiliencia de los socorristas y sobrevivientes, buscamos aprovechar la tecnología para asistir en la prevención y respuesta ante desastres.',
        'acknowledgementsProjectLeaders': 'Líderes del Proyecto',
        'acknowledgementsProjectLeadersNames': 'Leah Wing\nNatasha Sustache',
        'acknowledgementsInspiration': 'Inspiración',
        'acknowledgementsInspirationNames': 'Natasha S.\nJustin J.\nRuth S.\nRoxanna G.\nKerry G.\nEleanor G.\nMelina A.\nOtros socorristas médicos de desastres',
        'acknowledgementsThankYou': 'Gracias',
        'acknowledgementsThankYouNames': 'Brian R.\nSiddartha S.\nNishant A.\nAparimit C.\nShreyansh M.\nBrian N.\nFuming Z.\nLimbani C.\nAdhiraj C.\nAdvait G.',
        'acknowledgementsThanksAlsoTo': 'Gracias también a',
        'acknowledgementsThanksAlsoToNames': 'Shriya S.\nNitya V.\nJonathan Z.\nKiran B. K.\nNgoc D. N.\nDia S.\nKhushi R.\nAastha A.\nArushi A.\nKhushii S.\nEric W.\nPaul D.\nKevin L.\nYona V.-A.\nSuryam G.\nShobhit M.\nEmmet H.\nBhargavi P.\nAtharva S.\nAhmed K.\nThuy N.\nAtonbara D.-K.\nNigel P.\nBryan C.\nGaurav S.\nTejovrash A.\nMethasith R.\nYasmeen M.\nBrijesh V.\nMena I.\nLuke T.\nAndrew T.\nAlbi M.\nNihar K.\nRishi P.\nPrasad A.\nSelena L.\nPhoebe L.\nRishab M.\nKhang N.\nAnh T.\nSnigdha T.\nYusef W.\nIan D’S.\nSapna P.\nShreya M.\nSarah W.\nEzinne O.\nDarrell M.\nEmma W.\nSha B.\nKhanh T. T. D.-M.\nChristopher G.\nJose A. O.\nJanet M.\nVikki R.\nCrystal P.\nVal N.\nChris D.\nSasha R.\nAshley W.\nJessica R.\nNoe H.\nA Fair Resolution, LLC',
        'acknowledgementsClosing': '',
        'doNotEnterPersonalNamesNote': 'No ingrese el nombre de ninguna persona en la tarea.',
        'lastUpdated': 'Última actualización',
        'legalDraftNotice': 'Este documento es un borrador pendiente de revisión legal final. Los marcadores entre corchetes se completarán antes del lanzamiento público.',
        'deleteAccount': 'Eliminar cuenta',
        'deleteAccountWarningTitle': '¿Eliminar su cuenta?',
        'deleteAccountWarningBody': 'Esto eliminará permanentemente su perfil y cerrará su sesión. Las tareas que creó o tiene asignadas se conservarán para su equipo pero serán anonimizadas (su nombre se reemplaza por "deleted_user"). Esta acción no se puede deshacer.',
        'deleteAccountConfirmPrompt': 'Escriba ELIMINAR para confirmar',
        'deleteAccountConfirmWord': 'ELIMINAR',
        'deleteAccountPasswordPrompt': 'Ingrese su contraseña para confirmar su identidad',
        'deleteAccountTransferLeadershipFirst': 'Usted lidera uno o más equipos activos. Transfiera el liderazgo a otro miembro desde la página del equipo antes de eliminar su cuenta.',
        'deleteAccountSuccess': 'Su cuenta ha sido eliminada.',
        'deleteAccountFailure': 'No se pudo eliminar la cuenta. Por favor, inténtelo de nuevo.',
        'accountRoleSwitchSubtitle': 'Los líderes de equipo pueden crear y administrar equipos',
        'changeRoleTitle': '¿Cambiar su rol?',
        'changeRoleToLeaderBody': 'Como líder de equipo puede crear equipos y administrar sus miembros y tareas. Puede volver a cambiar en cualquier momento.',
        'changeRoleToMemberBody': 'Como miembro del equipo ya no podrá crear ni administrar equipos. Si lidera un equipo activo, transfiera el liderazgo primero.',
        'changeRoleConfirm': 'Cambiar rol',
        'roleChangedTo': 'Su rol ahora es {role}.',
        'aFairResolutionLLC': 'A Fair Resolution, LLC',
        'aFairResolutionLLCDescription': 'A Fair Resolution, LLC es una organización dedicada a la prevención y resolución de disputas. Trabaja para crear soluciones innovadoras que ayuden a las comunidades a prevenir y resolver disputas y coordinar recursos durante tiempos desafiantes.',
        'kapokIcon': 'Icono de Kapok',
        'kapokIconDescription': 'Inspiración: El Árbol Viviente\n\nEn el corazón del diseño se encuentra un majestuoso árbol kapok, cuya copa extensa simboliza la robusta red de individuos unidos en una misión de respuesta a desastres. Cada hoja y rama representa los vínculos vitales entre los miembros del equipo, enfatizando la colaboración, la respuesta rápida y la fortaleza colectiva que impulsa la iniciativa de Kapok.',
        'diggingDeeperTechRoots': 'Profundizando: Raíces Tecnológicas',
        'diggingDeeperTechRootsDescription': 'Debajo del árbol, una intrincada red de raíces se despliega como una placa de circuito, ilustrando que la base de la operación de Kapok está profundamente integrada en tecnología avanzada. Esta fusión creativa de forma natural y precisión técnica habla de las estrategias modernas y adaptativas que el equipo emplea ante la adversidad. La aplicación Kapok fue hecha para ti.',
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
        'createYourFirstTeamToGetStarted': 'Crea tu primer equipo para comenzar con la coordinación de respuesta a desastres',
        'member': 'miembro',
        'members': 'miembros',
        'active': 'Activo',
        'inactive': 'Inactivo',
        'joinAnExistingTeamOrCreateANewOneToGetStarted': 'Únete a un equipo existente o crea uno nuevo para comenzar con la coordinación de respuesta a desastres.',
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
        'setUpANewTeamForDisasterReliefCoordination': 'Configura un nuevo equipo para coordinación de respuesta a desastres',
        'enterTeamName': 'Ingresa el nombre del equipo',
        'descriptionOptional': 'Descripción (Opcional)',
        'briefDescriptionOfTheTeamsPurpose': 'Breve descripción del propósito del equipo',
        'teamLeaderBenefits': 'Funcionalidades del Líder de Equipo',
        'teamLeaderBenefitsDescription': '• Generar códigos de equipo para que los miembros se unan\n• Ver y gestionar todas las tareas del equipo\n• Asignar tareas a miembros del equipo\n• Editar prioridades de tareas y estado de finalización\n• Gestionar miembros del equipo',
        'teamCreatedSuccessfullyWithCode': '¡Equipo "{teamName}" creado exitosamente! Código del equipo: {teamCode}',
        'youMustBeLoggedInToCreateTeams': 'Debes iniciar sesión para crear equipos',
        'joinATeam': 'Unirse a un Equipo',
        'enterTheTeamCodeProvidedByYourTeamLeader': 'Ingresa el código del equipo proporcionado por tu líder de equipo',
        'enter6CharacterTeamCode': 'Ingresa código de equipo de 6 caracteres',
        'pleaseEnterATeamCode': 'Por favor ingresa un código de equipo',
        'teamCodeMustBe6Characters': 'El código del equipo debe tener 6 caracteres',
        'howToGetATeamCode': 'Cómo obtener un código de equipo',
        'howToGetATeamCodeDescription': 'Pide a tu líder de equipo que te proporcione un código de equipo de 6 caracteres. Este código te permite unirte a su equipo y participar en la coordinación de respuesta a desastres.',
        'dontHaveATeamCodeCreateANewTeam': '¿No tienes un código de equipo? Crea un nuevo equipo',
        'youMustBeLoggedInToJoinTeams': 'Debes iniciar sesión para unirte a equipos',
        'successfullyJoinedTeam': '¡Te uniste exitosamente al equipo "{teamName}"!',
        'taskDetails': 'Detalles de la Tarea',
        'openTask': 'Abrir tarea',
        'taskDetailPageToBeImplemented': 'Página de detalles de tarea - Por implementar',
        'saveChanges': 'Guardar Cambios',
        'tapToChangeProfilePicture': 'Toca para cambiar la foto de perfil',
        'profilePictureChangeNotImplementedYet': 'Cambio de foto de perfil aún no implementado',
        'profileUpdatedSuccessfully': '¡Perfil actualizado exitosamente!',
        'editTeam': 'Editar Equipo',
        'leaveTeam': 'Dejar Equipo',
        'teamCodeCopiedToClipboard': 'Código del equipo copiado al portapapeles',
        'copyCode': 'Copiar Código',
        'share': 'Compartir',
        'manage': 'Gestionar',
        'viewAll': 'Ver Todo',
        'editTeamFunctionalityWillBeImplementedHere': 'La funcionalidad de editar equipo se implementará aquí.',
        'remove': 'Eliminar',
        'removeFromTeam': 'Eliminar del Equipo',
        'makeTeamLeader': 'Hacer Líder del Equipo',
        'transferLeadership': 'Transferir Liderazgo',
        'confirmTransferLeadership': '¿Transferir el liderazgo a este miembro? Seguirás siendo miembro pero ya no serás el líder.',
        'transferLeadershipSuccess': 'Liderazgo transferido exitosamente',
        'eligibleForLeadershipTransfer': 'Este miembro puede recibir el liderazgo (cuenta de Líder de Equipo)',
        'transferLeadershipDiscoverHintEligible':
            'Transferir liderazgo: abre el menú ⋮ arriba o expande un miembro abajo con cuenta de Líder de Equipo.',
        'transferLeadershipNoEligibleExplanation':
            'Solo puedes transferir el liderazgo a miembros que se registraron como Líder de Equipo. Las cuentas de Miembro de Equipo aún no pueden ser líderes. Invita a alguien con cuenta de Líder de Equipo, o pide a un miembro que cree esa cuenta y vuelva a unirse.',
        'transferLeadershipMemberNotEligibleSubtitle':
            'No puede recibir el liderazgo — se requiere cuenta de Líder de Equipo',
        'editTaskPageToBeImplemented': 'Página de editar tarea - Por implementar',

        // Admin Permissions Page
        'administratorPermissions': 'Permisos de Administrador',
        'permissionsPageDescription': 'Esta página documenta el modelo de permisos de la aplicación Kapok. Cada acción está restringida a roles específicos.',
        'action': 'Acción',
        'whoCanPerform': 'Quién Puede Realizar',
        'viewTeam': 'Ver Equipo',
        'deleteTeam': 'Eliminar Equipo',
        'viewAllTeams': 'Ver Todos los Equipos',
        'anyTeamMember': 'Cualquier miembro del equipo',
        'teamLeaderOnly': 'Solo Líder de Equipo',
        'anyMemberExceptLeader': 'Cualquier miembro (excepto líder)',
        'adminOnly': 'Solo Administrador',
        'adminFeaturesPlannedNote': 'Nota: Algunas acciones específicas de administrador (como "Ver Todos los Equipos" y "Eliminar Equipo") están planificadas pero aún no son completamente funcionales en el backend.',

        // Profile Permissions Table
        'permissions': 'Permisos',
        'editOwnTasks': 'Editar Tareas Propias',
        'editAllTasks': 'Editar Todas las Tareas',
        'yourRole': 'Tu Rol',

        // Alpha-feedback localization pass
        'statusLabel': 'Estado',
        'titleLabel': 'Título',
        'all': 'Todos',
        'apply': 'Aplicar',
        'unassigned': 'Sin asignar',
        'ok': 'Aceptar',
        'next': 'Siguiente',
        'skip': 'Omitir',
        'getStarted': 'Comenzar',
        'help': 'Ayuda',
        'edit': 'Editar',
        'delete': 'Eliminar',
        'dismiss': 'Descartar',
        'created': 'Creada',
        'coordinatesValue': 'Coordenadas: {coords}',
        'genericError': 'Algo salió mal. Por favor, inténtelo de nuevo.',
        'highPriority': 'Prioridad alta',
        'mediumPriority': 'Prioridad media',
        'lowPriority': 'Prioridad baja',
        'synced': 'Sincronizado',
        'pendingCount': '{count} pendientes',
        'pageNotFound': 'Página no encontrada',
        'pageNotFoundDescription': 'La página que busca no existe.',
        'goHome': 'Ir al inicio',
        'chooseYourRole': 'Elija su rol',
        'selectYourRoleToGetStarted': 'Seleccione su rol para comenzar',
        'teamLeaderRoleDescription': 'Crear y administrar un equipo',
        'teamMemberRoleDescription': 'Unirse a un equipo existente',
        'adminRoleDescription': 'Supervisar todos los equipos y tareas',
        'mustBeLoggedInToSelectRole': 'Debe iniciar sesión para seleccionar un rol',
        'noSignedInUser': 'No ha iniciado sesión. Inicie sesión de nuevo.',
        'selectRoleFailed': 'No se pudo guardar su rol. Por favor, inténtelo de nuevo.',
        'mapsStoredOffline': 'Mapas guardados sin conexión',
        'noCachedRegions': 'No hay regiones guardadas',
        'downloadRegionFromMapPage': 'Descargue una región desde la página del mapa',
        'cachedMapsExplanation': 'Estos son los mapas guardados temporalmente sin conexión. Se descargan cuando hace zoom en una nueva ubicación en Mapas para que pueda ver el mapa sin conexión a internet. Puede eliminarlos con Limpiar Caché en la configuración para liberar espacio.',
        'latestRegion': 'Región más reciente',
        'allSavedRegions': 'Todas las regiones guardadas ({count})',
        'downloadedOn': 'Descargada: {date}',
        'tilesProgress': '{done}/{total} mosaicos',
        'regionCenter': 'Centro',
        'boundingBox': 'Área delimitada',
        'zoomRange': 'Rango de zoom',
        'tiles': 'Mosaicos',
        'cachedRegionPreview': 'Vista previa de la región guardada - Centro: {coords}',
        'loadRegionsFailed': 'No se pudieron cargar sus mapas sin conexión. Por favor, inténtelo de nuevo.',
        'couldNotGetYourLocation': 'No se pudo obtener su ubicación actual. Compruebe que el acceso a la ubicación esté permitido.',
        'viewOfflineMaps': 'Ver mapas sin conexión',
        'mapLoadFailed': 'No se pudo cargar el mapa. Por favor, inténtelo de nuevo.',
        'loadingMapForYourLocation': 'Cargando el mapa de su ubicación...',
        'mapWaitingForRegion': 'El mapa aún no se ha cargado.',
        'refreshOfflineRegion': 'Actualizar región sin conexión',
        'filterMarkers': 'Filtrar marcadores',
        'filterMapMarkers': 'Filtrar marcadores del mapa',
        'onboardingWelcomeTitle': 'Bienvenido a Kapok',
        'onboardingWelcomeBody': 'Coordine la respuesta ante desastres con su equipo. Administre tareas, siga el progreso y responda a emergencias de forma eficiente.',
        'onboardingOfflineTitle': 'Funciona totalmente sin conexión',
        'onboardingOfflineBody': '¿Sin internet? No hay problema. Cree tareas, administre equipos y coordine la respuesta incluso sin conexión. Todo se sincroniza automáticamente al volver a conectarse.',
        'onboardingTeamsTitle': 'Coordinación de equipos',
        'onboardingTeamsBody': 'Cree equipos con códigos de acceso únicos. Asigne roles, administre miembros y mantenga a todos al tanto de las prioridades y responsabilidades.',
        'onboardingTasksTitle': 'Gestión inteligente de tareas',
        'onboardingTasksBody': 'Cree tareas basadas en la ubicación con prioridades y categorías. Asígnelas a miembros del equipo, siga su estado y véalo todo en un mapa interactivo.',
        'dataMayBeOutdated': 'Los datos pueden estar desactualizados: la última sincronización fue hace más de 30 min',
        'anyDate': 'Cualquier fecha',
        'filterByDateCreated': 'Filtrar por fecha de creación',
        'customRange': 'Rango personalizado',
        'timeInStatusShort': '{time} en este estado',
        'onlyLeadersCanCreateTeams': 'Solo los líderes de equipo y los administradores pueden crear equipos',
        'teamCreatedTitle': '¡Equipo creado con éxito!',
        'teamNameValue': 'Nombre del equipo: {name}',
        'shareCodeWithYourTeamMembers': 'Comparta este código con los miembros de su equipo',
        'teamUpdatedSuccessfully': 'Equipo actualizado con éxito',
        'adminsHaveAccessToAllTeams': 'Los administradores tienen acceso a todos los equipos',
        'clearCacheConfirmBody': 'Esto borrará aproximadamente {size} KB de datos guardados en el dispositivo (tareas, equipos, filtros). Se conservan su idioma y tema. Deberá sincronizar de nuevo después.',
        'clearCacheFailed': 'No se pudieron borrar los datos guardados. Por favor, inténtelo de nuevo.',
        'deleteTaskConfirm': '¿Está seguro de que desea eliminar esta tarea? Esta acción no se puede deshacer.',
        'helpEditTaskTip': 'Toque el icono del lápiz para editar el nombre, la descripción, la prioridad y más.',
        'helpShareTaskTip': 'Use el botón de compartir para enviar los detalles de la tarea a otras personas.',
        'helpDeleteTaskTip': 'Toque el icono de la papelera para eliminar esta tarea de forma permanente.',
        'completing': 'Completar',
        'helpCompletingTaskTip': 'Cambie el estado a "Completada" con el menú de estado y guarde para marcar la tarea como terminada.',
        'shareTask': 'Compartir tarea',
        'pleaseEnterATitle': 'Por favor, ingrese un título',
        'timeInStatusNamed': 'Tiempo en {status}',
        'unknownDate': 'Fecha desconocida',
        'locationServicesDisabled': 'Los servicios de ubicación están desactivados',
        'locationPermissionDeniedPermanently': 'Permiso de ubicación denegado de forma permanente',
        'invalidCoordinatesReceived': 'Se recibieron coordenadas no válidas',
        'couldNotGetCurrentLocation': 'No se pudo obtener la ubicación actual',
        'usingDefaultLocation': '{reason}. Se usará la ubicación predeterminada.',
        'locationSet': 'Ubicación establecida: {location}',
        'enterAddressOrSelectOnMap': 'Ingrese una dirección o seleccione una ubicación en el mapa',
        'addressNotFound': 'No se encontró esa dirección. Revísela e inténtelo de nuevo.',
        'helpTaskNameTitle': 'Nombre y descripción de la tarea',
        'helpTaskNameTip': 'Dé a la tarea un nombre claro (3–100 caracteres) y una descripción opcional.',
        'helpPriorityTip': 'Elija prioridad Baja, Media o Alta para que el equipo sepa qué atender primero.',
        'helpLocationTip': 'Toque el mapa o use el botón de ubicación para fijar la tarea en un lugar concreto.',
        'assignment': 'Asignación',
        'helpAssignmentTip': 'Asigne la tarea a un miembro del equipo o déjela sin asignar para que cualquiera la tome.',
        'taskCreatedNamed': 'Tarea "{title}" creada con éxito',
        'fetchingCurrentLocation': 'Obteniendo la ubicación actual...',
        'tapMapToSelectLocation': 'Toque el mapa para seleccionar la ubicación de su tarea',
        'pleaseEnterATaskTitle': 'Por favor, ingrese el título de la tarea',
        'titleTooLong': 'El título debe tener 100 caracteres o menos',
        'enterTaskDescriptionOptional': 'Ingrese la descripción de la tarea (opcional)',
        'descriptionTooLong': 'La descripción debe tener 500 caracteres o menos',
        'addressOrCoordinates': 'Dirección o coordenadas',
        'searchAddress': 'Buscar dirección',
        'teamRequired': 'Equipo *',
        'selectATeam': 'Seleccione un equipo',
        'pleaseSelectATeam': 'Por favor, seleccione un equipo',
        'selectTeamFirstToAssign': 'Seleccione primero un equipo para asignar la tarea',
        'selectATeamMember': 'Seleccione un miembro del equipo',
        'selectLocationOnMapOrAddress': 'Seleccione una ubicación en el mapa o ingrese una dirección',
        'teamDeletedSuccessfully': 'Equipo eliminado con éxito',
        'shareThisCodeWithTeamMembers': 'Comparta este código con los miembros del equipo',
        'joinMyTeamMessage': '¡Únase a mi equipo en Kapok! Código del equipo: {code}',
        'noMembersFound': 'No se encontraron miembros',
        'loadMembersFailed': 'No se pudieron cargar los miembros del equipo. Por favor, inténtelo de nuevo.',
        'leadsThisTeam': 'Lidera este equipo',
        'assignedTasksCount': 'Tareas asignadas ({count})',
        'noAssignedTasks': 'No hay tareas asignadas',
        'noTasksYetCreateOne': 'Aún no hay tareas. ¡Cree una para comenzar!',
        'loadTasksFailed': 'No se pudieron cargar las tareas. Por favor, inténtelo de nuevo.',
        'memberWillBeRemovedFrom': '{name} será eliminado de {team}.',
        'memberRemovedFromTeam': '{name} fue eliminado del equipo',
        'deleteTeamConfirm': '¿Está seguro de que desea eliminar este equipo de forma permanente? Esta acción no se puede deshacer. Todos los miembros serán retirados del equipo.',
        'deletingTeam': 'Eliminando equipo...',
        'leaveTeamConfirm': '¿Está seguro de que desea salir de {team}? Las tareas que tenga asignadas en este equipo quedarán sin asignar.',
        'youHaveLeftTeam': 'Ha salido de {team}',
      },
    };

    return localizedValues[locale.languageCode]?[key] ?? key;
  }
}
