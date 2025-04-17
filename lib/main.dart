import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static const String _title = 'Qr Secure share';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'WorkSans', brightness: Brightness.light),
      darkTheme: ThemeData(fontFamily: 'WorkSans', brightness: Brightness.dark),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      title: MyApp._title,
      home: SplashPage(toggleTheme: _toggleTheme),
    );
  }
}