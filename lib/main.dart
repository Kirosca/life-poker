import 'package:flutter/material.dart';
import 'screens/todo_home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeBlackjackApp());
}

class LifeBlackjackApp extends StatefulWidget {
  const LifeBlackjackApp({super.key});

  @override
  State<LifeBlackjackApp> createState() => _LifeBlackjackAppState();
}

class _LifeBlackjackAppState extends State<LifeBlackjackApp> {
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
      title: 'Life-Blackjack Todo',
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
