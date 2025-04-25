import 'package:flutter/material.dart';
import 'package:smart_lock_pro/utils/responsive_helper.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // Static styles
  static final TextStyle _headingStyleBase = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static final TextStyle _subheadingStyleBase = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static final TextStyle _bodyStyleBase = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  // Responsive styles
  static TextStyle getHeadingStyle(BuildContext context) {
    return _headingStyleBase.copyWith(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        defaultSize: 24,
        smallScreenSize: 20,
        largeScreenSize: 28,
      ),
    );
  }

  static TextStyle getSubheadingStyle(BuildContext context) {
    return _subheadingStyleBase.copyWith(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        defaultSize: 18,
        smallScreenSize: 16,
        largeScreenSize: 20,
      ),
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return _bodyStyleBase.copyWith(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        defaultSize: 14,
        smallScreenSize: 12,
        largeScreenSize: 16,
      ),
    );
  }

  // For backward compatibility
  static final TextStyle headingStyle = _headingStyleBase;
  static final TextStyle subheadingStyle = _subheadingStyleBase;
  static final TextStyle bodyStyle = _bodyStyleBase;

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}
