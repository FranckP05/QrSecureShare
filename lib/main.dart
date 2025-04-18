import 'dart:io' show Platform; // Add for Platform check
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Add for FFI
import 'pages/splash_page.dart'; // Adjust path based on your structure

void main() {
  // Initialize databaseFactory for sqflite_common_ffi on desktop platforms
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

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