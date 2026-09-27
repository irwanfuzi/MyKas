import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import '../../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final String savedPin;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.savedPin,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  String _enteredPin = '';
  bool _isBiometricSupported = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat aplikasi dibuka kembali dari background, persiapkan biometrik
    if (state == AppLifecycleState.resumed && _isBiometricSupported) {
      _checkBiometricSupport();
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _isBiometricSupported = canAuthenticateWithBiometrics || isDeviceSupported;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Gunakan Sidik Jari / Biometrik untuk masuk ke MyKas',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        widget.onUnlocked();
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autentikasi biometrik gagal. Gunakan PIN MyKas.'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _onKeyPress(String value) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (_enteredPin == widget.savedPin) {
      widget.onUnlocked();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Salah! Silakan coba lagi.'),
          backgroundColor: AppTheme.expenseRed,
        ),
      );
      setState(() {
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: AppTheme.brandPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Masukkan PIN MyKas',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi Terkunci untuk Keamanan',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Indikator PIN (4 Titik)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final bool isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppTheme.brandPrimary : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? AppTheme.brandPrimary : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Tombol Biometrik PWA
            if (_isBiometricSupported) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    side: const BorderSide(color: AppTheme.brandPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _authenticateWithBiometrics,
                  icon: const Icon(Icons.fingerprint, color: AppTheme.brandPrimary, size: 28),
                  label: Text(
                    'Buka dengan Biometrik',
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Keypad Angka Numpad (1-9, Delete, 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((num) => _buildKeypadButton(num, colorScheme)).toList(),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 70, height: 70),
                      _buildKeypadButton('0', colorScheme),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: IconButton(
                          onPressed: _onDelete,
                          icon: Icon(Icons.backspace_outlined, color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label, ColorScheme colorScheme) {
    return SizedBox(
      width: 70,
      height: 70,
      child: InkWell(
        onTap: () => _onKeyPress(label),
        borderRadius: BorderRadius.circular(35),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
