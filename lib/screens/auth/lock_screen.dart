import 'package:flutter/foundation.dart';
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
  bool _isAuthenticating = false;

  // Deteksi apakah aplikasi berjalan sebagai Native Mobile (bukan PWA / Web)
  bool get _isNativeMobile => !kIsWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Jika di Android/iOS Native, jalankan pemicu Biometrik Otomatis saat layar muncul
    if (_isNativeMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateWithBiometrics();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat aplikasi resume dari background di Native Mobile, otomatis panggil biometrik lagi
    if (state == AppLifecycleState.resumed && _isNativeMobile) {
      _authenticateWithBiometrics();
    }
  }

  // Fungsi Panggil Biometrik Native
  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (canCheck) {
        final bool authenticated = await _auth.authenticate(
          localizedReason: 'Pindai Sidik Jari / Face ID untuk membuka MyKas',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          widget.onUnlocked();
        }
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _onKeyPress(String value) {
    final int targetLength = widget.savedPin.isNotEmpty ? widget.savedPin.length : 6;

    if (_enteredPin.length < targetLength) {
      setState(() {
        _enteredPin += value;
      });

      if (_enteredPin.length == targetLength) {
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
    final int targetLength = widget.savedPin.isNotEmpty ? widget.savedPin.length : 6;

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
              _isNativeMobile
                  ? 'Gunakan Biometrik atau PIN Keamanan'
                  : 'Aplikasi Terkunci untuk Keamanan',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Indikator Titik PIN 6 Digit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(targetLength, (index) {
                final bool isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
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

            // Tombol Manual Biometrik HANYA DITAMPILKAN pada APK Native
            if (_isNativeMobile) ...[
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
                    'Pindai Biometrik',
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

            // Keypad Numpad
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
