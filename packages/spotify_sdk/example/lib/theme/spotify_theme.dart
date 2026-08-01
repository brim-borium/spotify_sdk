import 'package:flutter/material.dart';

/// Design system and theme definitions for Spotify SDK Example App.
/// Uses a modern Light Identity with soft pastel accents.
abstract class SpotifyTheme {
  // Pastel Palette Colors
  /// Primary pastel mint green
  static const Color pastelMint = Color(0xFF52C498);

  /// Secondary pastel lavender
  static const Color pastelLavender = Color(0xFFC39AE7);

  /// Pastel coral accent
  static const Color pastelCoral = Color(0xFFFFA099);

  /// Soft sky blue accent
  static const Color pastelBlue = Color(0xFF8EC5FC);

  /// Warm pastel yellow accent
  static const Color pastelYellow = Color(0xFFFFE082);

  /// Light background color
  static const Color backgroundLight = Color(0xFFF7F9FC);

  /// Surface card background
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// Subtle border / divider color
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Dark text primary
  static const Color textDarkPrimary = Color(0xFF1E293B);

  /// Dark text secondary
  static const Color textDarkSecondary = Color(0xFF64748B);

  /// Light pastel red for errors
  static const Color errorPastel = Color(0xFFF87171);

  /// Light pastel green for success
  static const Color successPastel = Color(0xFF34D399);

  /// Linear gradient for the hero banner card
  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFFE0C3FC),
      Color(0xFF8EC5FC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns the configured light pastel [ThemeData].
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: pastelMint,
        secondary: pastelLavender,
        error: errorPastel,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDarkPrimary),
        titleTextStyle: TextStyle(
          color: textDarkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        selectedColor: pastelMint.withValues(alpha: 0.2),
        secondarySelectedColor: pastelLavender.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight),
        ),
        labelStyle: const TextStyle(
          color: textDarkPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelMint,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDarkPrimary,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: pastelMint,
        inactiveTrackColor: borderLight,
        thumbColor: pastelMint,
        overlayColor: pastelMint.withValues(alpha: 0.2),
        trackHeight: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: pastelMint,
        unselectedItemColor: textDarkSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
