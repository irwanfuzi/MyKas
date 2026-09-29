import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALET WARNA FINTECH MODERN ---
  static const Color brandPrimary = Color(0xFF2563EB); // Soft Royal Blue
  static const Color brandPrimaryLight = Color(0xFF3B82F6);
  static const Color brandPrimaryDark = Color(0xFF1D4ED8);

  static const Color brandAccent = Color(0xFFF59E0B); // Honey Gold
  static const Color brandAccentLight = Color(0xFFFBBF24);

  // Status Colors (Vibrant Clean)
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF97316);

  // --- SURFACE NEUTRAL LIGHT (WARM SOFT FINTECH WHITE) ---
  static const Color lightBg = Color(0xFFF1F5F9);        // Slate-tinted BG (Gak silau/mentah)
  static const Color lightSurface = Color(0xFFFFFFFF);   // Pure Card White
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);   // Micro Subtle Border
  static const Color lightTextPrimary = Color(0xFF0F172A); // High Contrast Slate
  static const Color lightTextSecondary = Color(0xFF64748B); // Soft Readable Grey

  // --- SURFACE NEUTRAL DARK (SLEEK CHARCOAL OLED) ---
  static const Color darkBg = Color(0xFF0B0E14);        // OLED Charcoal Base
  static const Color darkSurface = Color(0xFF151921);   // Subtle Card BG
  static const Color darkCard = Color(0xFF151921);
  static const Color darkBorder = Color(0xFF222732);   // Micro Border
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Crisp White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Soft Slate

  // Alias Kompatibilitas Kode Lama (Cegah Build Error)
  static const Color successGreen = incomeGreen;
  static const Color bgLight = lightBg;
  static const Color bgDark = darkBg;
  static const Color cardLight = lightCard;
  static const Color cardDark = darkCard;
  static const Color borderLight = lightBorder;
  static const Color borderDark = darkBorder;
  static const Color textPrimaryLight = lightTextPrimary;
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryLight = lightTextSecondary;
  static const Color textSecondaryDark = darkTextSecondary;

  // Corner Radius Standard (8px - 12px Restrained)
  static final BorderRadius radiusSmall = BorderRadius.circular(8.0);
  static final BorderRadius radiusMedium = BorderRadius.circular(10.0);
  static final BorderRadius radiusLarge = BorderRadius.circular(12.0);

  // --- LIGHT THEME DEFINITION ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: lightBg,
      
      colorScheme: const ColorScheme.light(
        primary: brandPrimary,
        onPrimary: Colors.white,
        secondary: brandAccent,
        onSecondary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
        outline: lightBorder,
        error: expenseRed,
      ),

      textTheme: GoogleFonts.urbanistTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        titleMedium: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge: const TextStyle(color: lightTextPrimary, fontSize: 14),
        bodyMedium: const TextStyle(color: lightTextSecondary, fontSize: 12),
      ),

      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0.5, // Soft subtle depth
        shadowColor: const Color(0xFF0F172A).withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: radiusLarge,
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.urbanist(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: brandPrimary, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: brandPrimary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 6,
      ),
    );
  }

  // --- DARK THEME DEFINITION ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: darkBg,

      colorScheme: const ColorScheme.dark(
        primary: brandPrimary,
        onPrimary: Colors.white,
        secondary: brandAccent,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        error: expenseRed,
      ),

      textTheme: GoogleFonts.urbanistTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        titleMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 14),
        bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 12),
      ),

      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLarge,
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.urbanist(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: brandPrimary, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: brandPrimaryLight,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
