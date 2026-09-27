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

  bool get _isNativeMobile => !kIsWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    if (state == AppLifecycleState.resumed && _isNativeMobile) {
      _authenticateWithBiometrics();
    }
  }

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
        SnackBar(
          content: Text(
            'PIN Salah! Silakan coba lagi.',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.expenseRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 20),

            // Flat Branding Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MYKAS',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // Flat Security Icon Box
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 28,
                  color: AppTheme.brandPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Masukkan PIN MyKas',
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isNativeMobile
                  ? 'Gunakan Biometrik atau PIN Keamanan'
                  : 'Aplikasi Terkunci demi Keamanan Data',
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 36),

            // Flat PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(targetLength, (index) {
                final bool isFilled = index < _enteredPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppTheme.brandPrimary : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? AppTheme.brandPrimary
                          : colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(flex: 3),

            // Flat Biometric Button (Khusus Native Mobile)
            if (_isNativeMobile) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppTheme.brandPrimary,
                      size: 22,
                    ),
                    label: Text(
                      'Pindai Biometrik',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Flat Numpad Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Column(
                children: [
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row
                            .map((num) => _buildKeypadButton(num, colorScheme))
                            .toList(),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 68, height: 68),
                      _buildKeypadButton('0', colorScheme),
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: InkWell(
                          onTap: _onDelete,
                          borderRadius: BorderRadius.circular(34),
                          child: Center(
                            child: Icon(
                              Icons.backspace_outlined,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label, ColorScheme colorScheme) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyPress(label),
          borderRadius: BorderRadius.circular(34),
          highlightColor: colorScheme.outline.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
