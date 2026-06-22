import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color deep    = Color(0xFF1A3C2E);
  static const Color mid     = Color(0xFF2D6A4F);
  static const Color accent  = Color(0xFF52B788);
  static const Color light   = Color(0xFFB7E4C7);
  static const Color surface = Color(0xFFF7F9F8);
  static const Color card    = Color(0xFFFFFFFF);
  static const Color border  = Color(0xFFE8EDEA);
  static const Color text1   = Color(0xFF0D1F17);
  static const Color text2   = Color(0xFF6B7F74);
  static const Color error   = Color(0xFFB71C1C);
  static const Color warning = Color(0xFFF9A825);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.mid,
      primary: AppColors.mid,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.surface,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.deep,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Bottom Nav Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.mid,
      unselectedItemColor: AppColors.text2,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deep,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.mid,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.mid),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      labelStyle: const TextStyle(color: AppColors.text2),
      hintStyle: const TextStyle(color: AppColors.text2),
      prefixIconColor: AppColors.mid,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.mid,
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.border),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.mid,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.deep,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Text
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineSmall: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AppColors.text1, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.text1, height: 1.6),
      bodyMedium: TextStyle(color: AppColors.text1, height: 1.5),
      bodySmall: TextStyle(color: AppColors.text2),
      labelSmall: TextStyle(color: AppColors.text2, fontSize: 11),
    ),

    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}


// ── Gradient helper ──────────────────────────────────────────────────────────
class AppGradients {
  static const LinearGradient header = LinearGradient(
    colors: [Color(0xFF0F2D20), Color(0xFF1A4A32), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFF1A3C2E), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splash = LinearGradient(
    colors: [Color(0xFF0F2D20), Color(0xFF1A3C2E), Color(0xFF52B788)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}