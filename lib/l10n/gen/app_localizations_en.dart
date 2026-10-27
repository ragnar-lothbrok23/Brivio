// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Construction Site Management';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get joinBrivio => 'Join Brivio';

  @override
  String get setUpAccount => 'Set up your site team account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get roleLabel => 'Role';

  @override
  String get logIn => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterName => 'Enter your name';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSent => 'Password reset email sent. Check your inbox.';

  @override
  String get roleBuilder => 'Builder / Owner';

  @override
  String get rolePm => 'Project Manager';

  @override
  String get roleSiteEngineer => 'Site Engineer';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleVendor => 'Vendor / Supplier';

  @override
  String get roleContractor => 'Contractor / Subcontractor';

  @override
  String get builderDashboard => 'Builder Dashboard';

  @override
  String get pmDashboard => 'PM Dashboard';

  @override
  String get siteEngineerDashboard => 'Site Engineer Dashboard';

  @override
  String get supervisorDashboard => 'Supervisor Dashboard';

  @override
  String get vendorDashboard => 'Vendor Dashboard';

  @override
  String get contractorDashboard => 'Contractor Dashboard';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get home => 'Home';

  @override
  String get projects => 'Projects';

  @override
  String get expenses => 'Expenses';

  @override
  String get more => 'More';

  @override
  String get tasks => 'Tasks';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get attendance => 'Attendance';

  @override
  String get progress => 'Progress';

  @override
  String get invoices => 'Invoices';

  @override
  String get teamChat => 'Team Chat';

  @override
  String get purchaseOrders => 'Purchase Orders';

  @override
  String get projectSummary => 'Project Summary';

  @override
  String get attendanceOverview => 'Attendance Overview';

  @override
  String get progressLogs => 'Progress Logs';

  @override
  String get photoTimeline => 'Photo Timeline';

  @override
  String get materialInventory => 'Material Inventory';

  @override
  String get safetyChecklists => 'Safety Checklists';

  @override
  String get contractorInvoices => 'Contractor Invoices';

  @override
  String get materialRequests => 'Material Requests';

  @override
  String get myProgressLog => 'My Progress Log';

  @override
  String get exportReport => 'Export Report';

  @override
  String get noScopeSet => 'No scope of work set yet — contact your PM.';

  @override
  String scopePrefix(String scope) {
    return 'Scope: $scope';
  }

  @override
  String get profileSettings => 'Profile & Settings';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get nameField => 'Name';

  @override
  String get save => 'Save';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get atLeast6Chars => 'At least 6 characters';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPresent => 'Present';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDispatched => 'Dispatched';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusSubmitted => 'Submitted';
}
