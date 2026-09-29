import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'screens/auth/lock_screen.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedPin = prefs.getString('user_pin') ?? '';
  final isPinEnabled = prefs.getBool('pin_enabled') ?? false;

  runApp(MyKasApp(
    initialSavedPin: savedPin,
    initialIsPinLocked: isPinEnabled && savedPin.isNotEmpty,
  ));
}

class MyKasApp extends StatefulWidget {
  final String initialSavedPin;
  final bool initialIsPinLocked;

  const MyKasApp({
    super.key,
    required this.initialSavedPin,
    required this.initialIsPinLocked,
  });

  @override
  State<MyKasApp> createState() => _MyKasAppState();
}

class _MyKasAppState extends State<MyKasApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late bool _isLocked;
  String _currentSavedPin = '';

  @override
  void initState() {
    super.initState();
    _isLocked = widget.initialIsPinLocked;
    _currentSavedPin = widget.initialSavedPin;
  }

  void _updateThemeMode(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  void _handleThemeChange(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _handlePinStateChanged(bool enabled, String newPin) {
    setState(() {
      _currentSavedPin = newPin;
      if (!enabled) {
        _isLocked = false;
      }
    });
  }

  // Builder untuk Widget App Utama
  Widget _buildMainApp(BuildContext context) {
    return App(
      onThemeChanged: _handleThemeChange,
      currentThemeMode: _themeMode,
      onThemeModeChanged: _updateThemeMode,
      onPinStateChanged: _handlePinStateChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyKas - Own Your Money',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) {
          // Jika aplikasi terkunci, buka SplashScreen -> LockScreen
          if (_isLocked) {
            return SplashScreen(
              nextScreen: LockScreen(
                savedPin: _currentSavedPin,
                onUnlocked: () {
                  // KUNCI PERBAIKAN: Ganti seluruh tumpukan halaman dengan App()
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => _buildMainApp(context),
                    ),
                    (route) => false,
                  );
                },
              ),
            );
          }
          // Jika tidak terkunci, langsung buka halaman App
          return _buildMainApp(context);
        },
      ),
    );
  }
}
