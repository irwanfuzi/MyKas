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

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  String _enteredPin = '';
  bool _isAuthenticating = false;
  bool _showPinPad = false;

  bool get _isNativeMobile => !kIsWeb;

  @override
  void initState() {
    super.initState();

    if (_isNativeMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateWithFingerprint();
      });
    } else {
      _showPinPad = true;
    }
  }

  // Panggil Khusus Pemindai Sidik Jari (Fingerprint)
  Future<void> _authenticateWithFingerprint() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (canCheck) {
        final bool authenticated = await _auth.authenticate(
          localizedReason: 'Tempelkan Sidik Jari untuk membuka MyKas',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true, // Murni Sidik Jari
          ),
        );

        if (authenticated) {
          widget.onUnlocked();
        }
      }
    } catch (e) {
      debugPrint('Fingerprint error: $e');
      setState(() {
        _showPinPad = true;
      });
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

            // Header Logo MyKas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
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

            const Spacer(),

            // METODE UTAMA SIDIK JARI (NATIVE MOBILE)
            if (_isNativeMobile && !_showPinPad) ...[
              GestureDetector(
                onTap: _authenticateWithFingerprint,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.brandPrimary,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 56,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tempelkan Sidik Jari Anda',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sentuh pemindai sidik jari untuk masuk',
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPinPad = true;
                  });
                },
                child: Text(
                  'Gunakan PIN 6-Digit',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]

            // METODE FALLBACK PIN KEYPAD
            else ...[
              Text(
                'Masukkan PIN MyKas',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
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

              const Spacer(),

              if (_isNativeMobile) ...[
                IconButton(
                  onPressed: _authenticateWithFingerprint,
                  icon: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppTheme.brandPrimary,
                    size: 32,
                  ),
                  tooltip: 'Gunakan Sidik Jari',
                ),
                const SizedBox(height: 12),
              ],

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
              const SizedBox(height: 24),
            ],
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
