import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF00CC44);
  static const Color secondaryGreen = Color(0xFFC8D655);
  static const Color accentTeal = Color(0xFF0BE3C7);
  static const Color darkTeal = Color(0xFF01A0AC);
  
  // Neutral Colors
  static const Color lightGray = Color(0xFFE8ECEE);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF374151);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1F2937);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF8F9FA);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Colors
      primarySwatch: _createMaterialColor(AppColors.primaryGreen),
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentTeal,
        surface: AppColors.white,
        background: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onBackground: AppColors.black,
        onError: AppColors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
        iconTheme: IconThemeData(
          color: AppColors.black,
          size: 24,
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      
      // Card Theme
     cardTheme: const CardThemeData(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.mediumGray,
          fontFamily: 'Cairo',
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkGray,
          fontFamily: 'Cairo',
          fontSize: 16,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        
        // Titles
        titleLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        
        // Body Text
        bodyLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mediumGray,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.mediumGray,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.mediumGray,
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.primaryGreen,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
      ),
      
      // Font Family
      fontFamily: 'Cairo',
    );
  }
  
  static ThemeData get darkTheme {
    // For future implementation
    return lightTheme;
  }
  
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;
    
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}