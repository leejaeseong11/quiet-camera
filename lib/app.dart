import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class QuietCameraApp extends StatelessWidget {
  const QuietCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiet Camera',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Quiet Camera',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
