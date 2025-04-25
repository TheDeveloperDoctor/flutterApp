import 'package:flutter/material.dart';
import 'package:smart_lock_pro/screens/splash_screen.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

void main() {
  runApp(const SmartLockProApp());
}

class SmartLockProApp extends StatelessWidget {
  const SmartLockProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lock Pro',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
