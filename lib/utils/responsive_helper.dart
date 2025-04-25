import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 && 
           MediaQuery.of(context).size.width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static bool isExtraLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T defaultValue,
    T? smallScreenValue,
    T? mediumScreenValue,
    T? largeScreenValue,
    T? extraLargeScreenValue,
  }) {
    if (isExtraLargeScreen(context) && extraLargeScreenValue != null) {
      return extraLargeScreenValue;
    }
    if (isLargeScreen(context) && largeScreenValue != null) {
      return largeScreenValue;
    }
    if (isMediumScreen(context) && mediumScreenValue != null) {
      return mediumScreenValue;
    }
    if (isSmallScreen(context) && smallScreenValue != null) {
      return smallScreenValue;
    }
    return defaultValue;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(
      getResponsiveValue<double>(
        context: context,
        defaultValue: 16.0,
        smallScreenValue: 12.0,
        largeScreenValue: 24.0,
      ),
    );
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double defaultSize,
    double? smallScreenSize,
    double? largeScreenSize,
  }) {
    return getResponsiveValue<double>(
      context: context,
      defaultValue: defaultSize,
      smallScreenValue: smallScreenSize ?? defaultSize * 0.8,
      largeScreenValue: largeScreenSize ?? defaultSize * 1.2,
    );
  }
}