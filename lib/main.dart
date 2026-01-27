import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'pages/timer_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TimerPage(),
    );
  }
}
