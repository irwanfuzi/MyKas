import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1: Bodi Utama (0.0s - 0.4s)
  late Animation<double> _baseScale;
  late Animation<double> _baseFade;

  // Phase 1.5: Inner Fold / Garis Putih (0.2s - 0.5s)
  late Animation<Offset> _innerFoldSlide;
  late Animation<double> _innerFoldFade;

  // Phase 2: The Golden Snap & Pulse (0.4s - 0.8s)
  late Animation<Offset> _goldLatchSlide;
  late Animation<double> _goldLatchScale;
  late Animation<double> _buttonPulse;

  // Phase 3: Exit Fade (1.0s - 1.3s)
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Total Durasi Sesuai Choreography (1.3 Detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // --- Phase 1: Bodi Biru (0.0s - 0.4s) ---
    _baseScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.31, curve: Curves.easeOutBack),
      ),
    );
    _baseFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.23, curve: Curves.easeIn),
      ),
    );

    // --- Phase 1.5: Garis Putih / Inner Slot (0.2s - 0.5s) ---
    _innerFoldSlide = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.38, curve: Curves.easeOut),
      ),
    );
    _innerFoldFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.38, curve: Curves.easeIn),
      ),
    );

    // --- Phase 2: Honey Gold Snap & Bounce (0.4s - 0.8s) ---
    _goldLatchSlide = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.31, 0.61, curve: Curves.elasticOut),
      ),
    );
    _goldLatchScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.31, 0.61, curve: Curves.easeOutBack),
      ),
    );
    _buttonPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.53, 0.69, curve: Curves.elasticOut),
      ),
    );

    // --- Phase 3: Exit Fade Out (1.0s - 1.3s) ---
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.77, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFade,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AREA LOGO DENGAN ANAMORPHIC LAYERING
                  SizedBox(
                    width: 120,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Phase 1: Bodi Biru Utama (Outer Wallet)
                        FadeTransition(
                          opacity: _baseFade,
                          child: ScaleTransition(
                            scale: _baseScale,
                            child: Container(
                              width: 100,
                              height: 76,
                              decoration: BoxDecoration(
                                color: AppTheme.brandPrimary, // Soft Royal Blue
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.brandPrimary.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. Phase 1.5: Inner Fold / Slot Garis Putih
                        Positioned(
                          left: 18,
                          child: FadeTransition(
                            opacity: _innerFoldFade,
                            child: SlideTransition(
                              position: _innerFoldSlide,
                              child: Container(
                                width: 50,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 3. Phase 2: Golden Latch (Pengunci Honey Gold) + Micro-Bounce
                        Positioned(
                          right: 4,
                          child: SlideTransition(
                            position: _goldLatchSlide,
                            child: ScaleTransition(
                              scale: _goldLatchScale,
                              child: Container(
                                width: 36,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B), // Honey Gold
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(6),
                                    bottomLeft: Radius.circular(6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  // Tombol Putih (Pulse Pop)
                                  child: ScaleTransition(
                                    scale: _buttonPulse,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // BRANDING TEXT (Fade In bersamaan)
                  FadeTransition(
                    opacity: _baseFade,
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.urbanist(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                            children: [
                              TextSpan(
                                text: 'MY',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              const TextSpan(
                                text: 'KAS',
                                style: TextStyle(color: AppTheme.brandPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'OWN YOUR MONEY',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
