import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'l10n/gen/app_localizations.dart';
import 'screens/splash_screen.dart';

const _themeModePrefKey = 'themeMode';
const _languageCodePrefKey = 'languageCode';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BrivioApp());
}

class BrivioApp extends StatefulWidget {
  const BrivioApp({super.key});

  /// Finds the nearest app state so descendants (e.g. the Profile screen)
  /// can read/toggle the theme — no state-management package added, this
  /// matches the plain StatefulWidget style used everywhere else in the app.
  static BrivioAppState of(BuildContext context) {
    return context.findAncestorStateOfType<BrivioAppState>()!;
  }

  @override
  State<BrivioApp> createState() => BrivioAppState();
}

class BrivioAppState extends State<BrivioApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadLocale();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModePrefKey) ?? false;
    if (mounted && isDark) setState(() => _themeMode = ThemeMode.dark);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    setState(() => _themeMode = enabled ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModePrefKey, enabled);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageCodePrefKey);
    if (mounted && code != null) setState(() => _locale = Locale(code));
  }

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    setState(() => _locale = Locale(languageCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodePrefKey, languageCode);
  }

  /// Called once a user's Firestore profile loads (see AuthGate), so a
  /// language chosen on another device follows the account rather than
  /// staying stuck on whatever this device's local cache last had.
  void syncLocaleWithUser(String languageCode) {
    if (languageCode == _locale.languageCode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => setLocale(languageCode));
  }

  static const _brandOrange = Color(0xFFFF7A3D);
  static const _cream = Color(0xFFFBF6EF);

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(seedColor: _brandOrange, brightness: brightness);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: brightness == Brightness.light ? _cream : null,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: brightness == Brightness.light ? _cream : null,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        filled: true,
      ),
      // Smooth horizontal slide+fade between screens on every platform,
      // instead of the default (which can read as an abrupt cut on some
      // Android configurations).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brivio',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
