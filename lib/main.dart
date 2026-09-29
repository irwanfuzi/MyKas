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
  bool _showSplash = true;
  late bool _isLocked;
  late String _currentSavedPin;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.initialIsPinLocked;
    _currentSavedPin = widget.initialSavedPin;

    // Timer disesuaikan dengan durasi animasi SplashScreen asli (2.5 detik)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyKas - Own Your Money',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Menggunakan SplashScreen asli tanpa _SimpleSplashScreen
      home: _showSplash
          ? const SplashScreen()
          : (_isLocked
              ? LockScreen(
                  savedPin: _currentSavedPin,
                  onUnlocked: () {
                    setState(() {
                      _isLocked = false;
                    });
                  },
                )
              : App(
                  onThemeChanged: _handleThemeChange,
                  currentThemeMode: _themeMode,
                  onThemeModeChanged: _updateThemeMode,
                  onPinStateChanged: _handlePinStateChanged,
                )),
    );
  }
}
