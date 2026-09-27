import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lockAppIfEnabled();
    } else if (state == AppLifecycleState.resumed) {
      _lockAppIfEnabled();
    }
  }

  Future<void> _lockAppIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin') ?? '';
    final isPinEnabled = prefs.getBool('pin_enabled') ?? false;

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

// Widget Tampilan Utama jika main.dart juga memuat MainNavigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width < 600) {
                return const SizedBox.shrink();
              }
              return NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                // Sinkronisasi warna unselected (Gantikan unselectedItemColor yang invalid)
                unselectedIconTheme: IconThemeData(
                  color: AppTheme.textSecondary,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
                selectedIconTheme: IconThemeData(
                  color: theme.colorScheme.primary,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'MyKas',
                    // Sinkronisasi FontWeight.black -> FontWeight.w900 (Identik secara visual)
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Beranda'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics),
                    label: Text('Analisis'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add_circle_outline),
                    selectedIcon: Icon(Icons.add_circle),
                    label: Text('Catat'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: Text('Riwayat'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profil'),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: Text(
                  'MyKas Dashboard',
                  // Sinkronisasi FontWeight.extrabold -> FontWeight.w800 (Identik secara visual)
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
