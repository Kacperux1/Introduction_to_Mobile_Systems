import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isHighContrast = false;
  bool _isVoiceFeedbackEnabled = false;
  double _volume = 0.5;
  Locale _locale = const Locale('en', 'US');
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkLoginStatus();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_locale.toLanguageTag());
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      _isHighContrast = prefs.getBool('high_contrast') ?? false;
      _isVoiceFeedbackEnabled = prefs.getBool('voice_feedback') ?? false;
      _volume = prefs.getDouble('volume') ?? 0.5;
      
      String langCode = prefs.getString('language_code') ?? 'en';
      String countryCode = prefs.getString('country_code') ?? 'US';
      _locale = Locale(langCode, countryCode);
    });
    _updateTtsLanguage();
    await _flutterTts.setVolume(_volume);
  }

  Future<void> _updateTtsLanguage() async {
    String tag = _locale.languageCode == 'pl' ? 'pl-PL' : 'en-US';
    await _flutterTts.setLanguage(tag);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() => _themeMode = mode);
    _speak(_locale.languageCode == 'pl' ? "Tryb motywu zmieniony" : "Theme mode changed");
  }

  Future<void> _toggleHighContrast(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
    setState(() => _isHighContrast = value);
    if (value) {
      _speak(_locale.languageCode == 'pl' ? "Wysoki kontrast włączony" : "High contrast enabled");
    } else {
      _speak(_locale.languageCode == 'pl' ? "Wysoki kontrast wyłączony" : "High contrast disabled");
    }
  }

  Future<void> _changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
    setState(() {
      _locale = locale;
    });
    await _updateTtsLanguage();
    _speak(_locale.languageCode == 'pl' ? "Język zmieniony na polski" : "Language changed to English");
  }

  Future<void> _toggleVoiceFeedback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_feedback', value);
    setState(() => _isVoiceFeedbackEnabled = value);
    if (value) {
      await _flutterTts.speak(_locale.languageCode == 'pl' ? "Informacje głosowe włączone" : "Voice feedback enabled");
    }
  }

  Future<void> _updateVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
    setState(() => _volume = value);
    await _flutterTts.setVolume(value);
  }

  Future<void> _speak(String text) async {
    if (_isVoiceFeedbackEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() => _isLoggedIn = token != null);
  }

  void _handleLoginSuccess() {
    setState(() => _isLoggedIn = true);
    _speak(_locale.languageCode == 'pl' ? "Zalogowano pomyślnie. Witaj w aplikacji." : "Logged in successfully. Welcome.");
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    setState(() => _isLoggedIn = false);
    _speak(_locale.languageCode == 'pl' ? "Wylogowano" : "Logged out");
  }

  @override
  Widget build(BuildContext context) {
    const Color originalBlue = Color(0xFF00008B);
    const Color highContrastPurple = Color(0xFF301934);

    ThemeData getActiveTheme() {
      if (_isHighContrast) {
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: highContrastPurple,
          cardColor: Colors.black,
          canvasColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
          colorScheme: const ColorScheme.dark(
            primary: Colors.yellow,
            onPrimary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.yellow,
            secondary: Colors.yellow,
            outline: Colors.yellow,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.yellow),
            bodyMedium: TextStyle(color: Colors.yellow),
            titleLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.yellow),
          listTileTheme: const ListTileThemeData(textColor: Colors.yellow, iconColor: Colors.yellow),
          useMaterial3: true,
        );
      }

      if (_themeMode == ThemeMode.light) {
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          cardColor: const Color(0xFFEEEEEE),
          canvasColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.red, foregroundColor: Colors.white),
          colorScheme: ColorScheme.fromSeed(seedColor: originalBlue, brightness: Brightness.light).copyWith(
            primary: originalBlue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          useMaterial3: true,
        );
      } else if (_themeMode == ThemeMode.dark) {
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          cardColor: const Color(0xFF1E1E1E),
          canvasColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A1A), foregroundColor: Colors.white),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white,
          ),
          useMaterial3: true,
        );
      } else {
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: originalBlue,
          cardColor: const Color(0xFFE0E0E0),
          canvasColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.red, foregroundColor: Colors.white),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: originalBlue,
            surface: originalBlue,
            onSurface: Colors.black,
            secondary: Colors.red,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
          ),
          listTileTheme: const ListTileThemeData(textColor: Colors.white, iconColor: Colors.white),
          useMaterial3: true,
        );
      }
    }

    return ThemeSettings(
      themeMode: _themeMode,
      isHighContrast: _isHighContrast,
      isVoiceFeedbackEnabled: _isVoiceFeedbackEnabled,
      volume: _volume,
      locale: _locale,
      updateThemeMode: _saveThemeMode,
      updateHighContrast: _toggleHighContrast,
      updateVoiceFeedback: _toggleVoiceFeedback,
      updateVolume: _updateVolume,
      updateLocale: _changeLanguage,
      speak: _speak,
      child: MaterialApp(
        title: 'BookTrade',
        theme: getActiveTheme(),
        locale: _locale,
        supportedLocales: const [Locale('en', 'US'), Locale('pl', 'PL')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: _isLoggedIn
            ? HomeScreen(isLoggedIn: _isLoggedIn, onLogout: _handleLogout)
            : LoginScreen(onLoginSuccess: _handleLoginSuccess),
      ),
    );
  }
}

class ThemeSettings extends InheritedWidget {
  final ThemeMode themeMode;
  final bool isHighContrast;
  final bool isVoiceFeedbackEnabled;
  final double volume;
  final Locale locale;
  final Function(ThemeMode) updateThemeMode;
  final Function(bool) updateHighContrast;
  final Function(bool) updateVoiceFeedback;
  final Function(double) updateVolume;
  final Function(Locale) updateLocale;
  final Function(String) speak;

  const ThemeSettings({
    super.key,
    required this.themeMode,
    required this.isHighContrast,
    required this.isVoiceFeedbackEnabled,
    required this.volume,
    required this.locale,
    required this.updateThemeMode,
    required this.updateHighContrast,
    required this.updateVoiceFeedback,
    required this.updateVolume,
    required this.updateLocale,
    required this.speak,
    required super.child,
  });

  static ThemeSettings? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeSettings>();
  }

  @override
  bool updateShouldNotify(ThemeSettings oldWidget) {
    return themeMode != oldWidget.themeMode || 
           isHighContrast != oldWidget.isHighContrast ||
           isVoiceFeedbackEnabled != oldWidget.isVoiceFeedbackEnabled ||
           volume != oldWidget.volume ||
           locale != oldWidget.locale;
  }
}
