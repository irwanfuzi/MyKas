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

    // Splash screen tampil selama 2 detik, lalu otomatis pindah state
    Future.delayed(const Duration(seconds: 2), () {
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
      home: _showSplash
          ? const _SimpleSplashScreen()
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

// Widget Splash Sederhana Tanpa Navigator Push/Pop (Anti Stuck)
class _SimpleSplashScreen extends StatelessWidget {
  const _SimpleSplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0052FF).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 38,
                  color: Color(0xFF0052FF),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MYKAS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
