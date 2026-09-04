import 'package:flutter/material.dart';
import 'screens/todo_home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeBackjackApp());
}

class LifeBackjackApp extends StatefulWidget {
  const LifeBackjackApp({super.key});

  @override
  State<LifeBackjackApp> createState() => _LifeBackjackAppState();
}

class _LifeBackjackAppState extends State<LifeBackjackApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life-Backjack Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: TodoHomeScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
