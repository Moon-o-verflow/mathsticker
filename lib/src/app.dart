import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/presentation/home_screen.dart';

/// App-wide color palette
class AppColors {
  static const Color primary = Color(0xFF007AFF);       // iOS Blue
  static const Color primaryLight = Color(0xFF5AC8FA);  // iOS Light Blue
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF2F2F7);       // iOS System Gray 6
  static const Color surfaceLight = Color(0xFFF9F9FB);  // Lighter surface
  static const Color error = Color(0xFFFF3B30);         // iOS Red
  static const Color success = Color(0xFF34C759);       // iOS Green
  static const Color textPrimary = Color(0xFF1C1C1E);   // iOS Label
  static const Color textSecondary = Color(0xFF8E8E93); // iOS Secondary Label
  static const Color separator = Color(0xFFE5E5EA);     // iOS Separator
}

class MathStickerApp extends StatelessWidget {
  const MathStickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'MathSticker',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final monoTextStyle = GoogleFonts.jetBrainsMono();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Typography
      textTheme: baseTextTheme.copyWith(
        // For equation display - monospace
        headlineMedium: monoTextStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        // For keyboard keys
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // For labels
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // Elevated Button Theme (for keyboard keys)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
