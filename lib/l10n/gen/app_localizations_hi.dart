// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTagline => 'निर्माण स्थल प्रबंधन';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get joinBrivio => 'Brivio से जुड़ें';

  @override
  String get setUpAccount => 'अपनी साइट टीम का खाता बनाएं';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get fullNameLabel => 'पूरा नाम';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get logIn => 'लॉग इन करें';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get noAccountSignUp => 'खाता नहीं है? साइन अप करें';

  @override
  String get enterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get enterValidEmail => 'एक मान्य ईमेल दर्ज करें';

  @override
  String get enterPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get passwordMinLength => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get resetPasswordTitle => 'पासवर्ड रीसेट करें';

  @override
  String get resetPasswordInstructions =>
      'अपना ईमेल दर्ज करें और हम आपको पासवर्ड रीसेट करने के लिए एक लिंक भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get resetEmailSent =>
      'पासवर्ड रीसेट ईमेल भेज दिया गया है। अपना इनबॉक्स देखें।';

  @override
  String get roleBuilder => 'बिल्डर / मालिक';

  @override
  String get rolePm => 'प्रोजेक्ट मैनेजर';

  @override
  String get roleSiteEngineer => 'साइट इंजीनियर';

  @override
  String get roleSupervisor => 'सुपरवाइज़र';

  @override
  String get roleVendor => 'वेंडर / आपूर्तिकर्ता';

  @override
  String get roleContractor => 'ठेकेदार / उप-ठेकेदार';

  @override
  String get builderDashboard => 'बिल्डर डैशबोर्ड';

  @override
  String get pmDashboard => 'PM डैशबोर्ड';

  @override
  String get siteEngineerDashboard => 'साइट इंजीनियर डैशबोर्ड';

  @override
  String get supervisorDashboard => 'सुपरवाइज़र डैशबोर्ड';

  @override
  String get vendorDashboard => 'वेंडर डैशबोर्ड';

  @override
  String get contractorDashboard => 'ठेकेदार डैशबोर्ड';

  @override
  String welcomeUser(String name) {
    return 'स्वागत है, $name';
  }

  @override
  String get home => 'होम';

  @override
  String get projects => 'प्रोजेक्ट्स';

  @override
  String get expenses => 'खर्च';

  @override
  String get more => 'अधिक';

  @override
  String get tasks => 'कार्य';

  @override
  String get myTasks => 'मेरे कार्य';

  @override
  String get attendance => 'उपस्थिति';

  @override
  String get progress => 'प्रगति';

  @override
  String get invoices => 'इनवॉइस';

  @override
  String get teamChat => 'टीम चैट';

  @override
  String get purchaseOrders => 'खरीद आदेश';

  @override
  String get projectSummary => 'प्रोजेक्ट सारांश';

  @override
  String get attendanceOverview => 'उपस्थिति अवलोकन';

  @override
  String get progressLogs => 'प्रगति लॉग';

  @override
  String get photoTimeline => 'फोटो टाइमलाइन';

  @override
  String get materialInventory => 'सामग्री सूची';

  @override
  String get safetyChecklists => 'सुरक्षा चेकलिस्ट';

  @override
  String get contractorInvoices => 'ठेकेदार इनवॉइस';

  @override
  String get materialRequests => 'सामग्री अनुरोध';

  @override
  String get myProgressLog => 'मेरी प्रगति लॉग';

  @override
  String get exportReport => 'रिपोर्ट निर्यात करें';

  @override
  String get noScopeSet =>
      'अभी तक कोई कार्य क्षेत्र निर्धारित नहीं है — अपने PM से संपर्क करें।';

  @override
  String scopePrefix(String scope) {
    return 'क्षेत्र: $scope';
  }

  @override
  String get profileSettings => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get nameField => 'नाम';

  @override
  String get save => 'सेव करें';

  @override
  String get nameUpdated => 'नाम अपडेट हो गया';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get currentPasswordLabel => 'वर्तमान पासवर्ड';

  @override
  String get newPasswordLabel => 'नया पासवर्ड';

  @override
  String get enterCurrentPassword => 'अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String get atLeast6Chars => 'कम से कम 6 अक्षर';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get change => 'बदलें';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get language => 'भाषा';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusApproved => 'स्वीकृत';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get statusDelivered => 'वितरित';

  @override
  String get statusPresent => 'उपस्थित';

  @override
  String get statusAbsent => 'अनुपस्थित';

  @override
  String get statusAssigned => 'सौंपा गया';

  @override
  String get statusInProgress => 'प्रगति पर';

  @override
  String get statusDispatched => 'भेजा गया';

  @override
  String get statusPaid => 'भुगतान किया गया';

  @override
  String get statusSubmitted => 'प्रस्तुत';
}
