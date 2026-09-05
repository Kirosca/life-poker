import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'screens/main_poker_app.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifePokerApp());
}

class LifePokerApp extends StatefulWidget {
  const LifePokerApp({super.key});

  @override
  State<LifePokerApp> createState() => _LifePokerAppState();
}

class _LifePokerAppState extends State<LifePokerApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Sleek modern dark mode by default

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: _themeMode,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp(
          title: 'Life-Poker: 个人技能与时间块卡牌管理',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: MainPokerAppScreen(
            onToggleTheme: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
        );
      },
    );
  }
}
