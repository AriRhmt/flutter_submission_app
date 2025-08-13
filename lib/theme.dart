import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Updated primary color to #FF7043 as requested; tuned supporting colors for contrast
  static const Color primary = Color(0xFFFF7043);
  static const Color secondary = Color(0xFFFF8A65);
  static const Color accent = Color(0xFF26C6DA);
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0B0F1A);
  static const Color textSecondary = Color(0xFF637083);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputTheme(),
      elevatedButtonTheme: _buttonTheme(textTheme),
      cardTheme: _cardTheme(),
      dividerColor: Colors.black12,
      // Smooth transitions across platforms
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: const Color(0xFF1E1E2A),
        background: const Color(0xFF12121B),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF12121B),
      textTheme: _textTheme(textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputTheme(isDark: true),
      elevatedButtonTheme: _buttonTheme(textTheme),
      cardTheme: _cardTheme(isDark: true),
      dividerColor: Colors.white12,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      }),
    );
  }

  static TextTheme _textTheme(TextTheme t) => t.copyWith(
        displayMedium: t.displayMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
        titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
        bodyLarge: t.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 14, color: textSecondary),
        labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );

  static InputDecorationTheme _inputTheme({bool isDark = false}) => InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withOpacity(0.8), width: 1.5),
        ),
      );

  static ElevatedButtonThemeData _buttonTheme(TextTheme textTheme) => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  static CardTheme _cardTheme({bool isDark = false}) => CardTheme(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF1E1E2A) : surface,
        margin: EdgeInsets.zero,
      );
}