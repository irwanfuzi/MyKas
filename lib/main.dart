import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'screens/auth/lock_screen.dart';
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

class _MyKasAppState extends State<MyKasApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.dark;
  late bool _isLocked;
  String _currentSavedPin = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLocked = widget.initialIsPinLocked;
    _currentSavedPin = widget.initialSavedPin;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Mendeteksi saat PWA ditutup, di-minimize, atau pindah tab/aplikasi
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lockAppIfEnabled();
    }
  }

  Future<void> _lockAppIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin') ?? '';
    final isPinEnabled = prefs.getBool('pin_enabled') ?? false;

    // Kunci ulang aplikasi jika PIN / Biometrik diaktifkan
    if (isPinEnabled && savedPin.isNotEmpty) {
      setState(() {
        _currentSavedPin = savedPin;
        _isLocked = true;
      });
    }
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
      home: _isLocked
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
            ),
    );
  }
}
