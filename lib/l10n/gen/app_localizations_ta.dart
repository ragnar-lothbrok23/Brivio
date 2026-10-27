// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTagline => 'கட்டுமான தள மேலாண்மை';

  @override
  String get welcomeBack => 'மீண்டும் வருக';

  @override
  String get joinBrivio => 'Brivio-இல் இணையுங்கள்';

  @override
  String get setUpAccount => 'உங்கள் தள குழு கணக்கை அமைக்கவும்';

  @override
  String get createAccount => 'கணக்கை உருவாக்கு';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get passwordLabel => 'கடவுச்சொல்';

  @override
  String get fullNameLabel => 'முழு பெயர்';

  @override
  String get roleLabel => 'பங்கு';

  @override
  String get logIn => 'உள்நுழைக';

  @override
  String get signUp => 'பதிவு செய்க';

  @override
  String get noAccountSignUp => 'கணக்கு இல்லையா? பதிவு செய்யவும்';

  @override
  String get enterEmail => 'உங்கள் மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get enterValidEmail => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get enterPassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get enterName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get passwordMinLength =>
      'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get resetPasswordTitle => 'கடவுச்சொல்லை மீட்டமை';

  @override
  String get resetPasswordInstructions =>
      'உங்கள் மின்னஞ்சலை உள்ளிடவும், உங்கள் கடவுச்சொல்லை மீட்டமைக்க ஒரு இணைப்பை அனுப்புவோம்.';

  @override
  String get sendResetLink => 'மீட்டமை இணைப்பை அனுப்பு';

  @override
  String get resetEmailSent =>
      'கடவுச்சொல் மீட்டமைப்பு மின்னஞ்சல் அனுப்பப்பட்டது. உங்கள் இன்பாக்ஸைப் பார்க்கவும்.';

  @override
  String get roleBuilder => 'பில்டர் / உரிமையாளர்';

  @override
  String get rolePm => 'திட்ட மேலாளர்';

  @override
  String get roleSiteEngineer => 'தள பொறியாளர்';

  @override
  String get roleSupervisor => 'மேற்பார்வையாளர்';

  @override
  String get roleVendor => 'விற்பனையாளர் / சப்ளையர்';

  @override
  String get roleContractor => 'ஒப்பந்தக்காரர் / துணை ஒப்பந்தக்காரர்';

  @override
  String get builderDashboard => 'பில்டர் டாஷ்போர்டு';

  @override
  String get pmDashboard => 'PM டாஷ்போர்டு';

  @override
  String get siteEngineerDashboard => 'தள பொறியாளர் டாஷ்போர்டு';

  @override
  String get supervisorDashboard => 'மேற்பார்வையாளர் டாஷ்போர்டு';

  @override
  String get vendorDashboard => 'விற்பனையாளர் டாஷ்போர்டு';

  @override
  String get contractorDashboard => 'ஒப்பந்தக்காரர் டாஷ்போர்டு';

  @override
  String welcomeUser(String name) {
    return 'வரவேற்கிறோம், $name';
  }

  @override
  String get home => 'முகப்பு';

  @override
  String get projects => 'திட்டங்கள்';

  @override
  String get expenses => 'செலவுகள்';

  @override
  String get more => 'மேலும்';

  @override
  String get tasks => 'பணிகள்';

  @override
  String get myTasks => 'எனது பணிகள்';

  @override
  String get attendance => 'வருகை';

  @override
  String get progress => 'முன்னேற்றம்';

  @override
  String get invoices => 'விலைப்பட்டியல்கள்';

  @override
  String get teamChat => 'குழு அரட்டை';

  @override
  String get purchaseOrders => 'கொள்முதல் ஆணைகள்';

  @override
  String get projectSummary => 'திட்ட சுருக்கம்';

  @override
  String get attendanceOverview => 'வருகை மேலோட்டம்';

  @override
  String get progressLogs => 'முன்னேற்ற பதிவுகள்';

  @override
  String get photoTimeline => 'புகைப்பட காலவரிசை';

  @override
  String get materialInventory => 'பொருள் சரக்கு';

  @override
  String get safetyChecklists => 'பாதுகாப்பு சரிபார்ப்பு பட்டியல்';

  @override
  String get contractorInvoices => 'ஒப்பந்தக்காரர் விலைப்பட்டியல்கள்';

  @override
  String get materialRequests => 'பொருள் கோரிக்கைகள்';

  @override
  String get myProgressLog => 'எனது முன்னேற்ற பதிவு';

  @override
  String get exportReport => 'அறிக்கையை ஏற்றுமதி செய்';

  @override
  String get noScopeSet =>
      'இன்னும் பணி நோக்கம் அமைக்கப்படவில்லை — உங்கள் PM-ஐ தொடர்பு கொள்ளவும்.';

  @override
  String scopePrefix(String scope) {
    return 'நோக்கம்: $scope';
  }

  @override
  String get profileSettings => 'சுயவிவரம் & அமைப்புகள்';

  @override
  String get camera => 'கேமரா';

  @override
  String get gallery => 'கேலரி';

  @override
  String get nameField => 'பெயர்';

  @override
  String get save => 'சேமி';

  @override
  String get nameUpdated => 'பெயர் புதுப்பிக்கப்பட்டது';

  @override
  String get changePassword => 'கடவுச்சொல்லை மாற்று';

  @override
  String get currentPasswordLabel => 'தற்போதைய கடவுச்சொல்';

  @override
  String get newPasswordLabel => 'புதிய கடவுச்சொல்';

  @override
  String get enterCurrentPassword => 'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get atLeast6Chars => 'குறைந்தது 6 எழுத்துகள்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get change => 'மாற்று';

  @override
  String get darkMode => 'இருள் பயன்முறை';

  @override
  String get language => 'மொழி';

  @override
  String get statusPending => 'நிலுவையில்';

  @override
  String get statusApproved => 'அங்கீகரிக்கப்பட்டது';

  @override
  String get statusRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get statusCompleted => 'முடிந்தது';

  @override
  String get statusDelivered => 'வழங்கப்பட்டது';

  @override
  String get statusPresent => 'வந்துள்ளார்';

  @override
  String get statusAbsent => 'வரவில்லை';

  @override
  String get statusAssigned => 'ஒதுக்கப்பட்டது';

  @override
  String get statusInProgress => 'நடைபெறுகிறது';

  @override
  String get statusDispatched => 'அனுப்பப்பட்டது';

  @override
  String get statusPaid => 'செலுத்தப்பட்டது';

  @override
  String get statusSubmitted => 'சமர்ப்பிக்கப்பட்டது';
}
