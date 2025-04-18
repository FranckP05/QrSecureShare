import 'package:flutter/material.dart';

// Classe pour gérer les thèmes de l'application
class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF1E88E5); // Bleu principal
  static const Color successColor = Color(0xFF4CAF50); // Vert pour les succès
  static const Color errorColor = Color(0xFFF44336); // Rouge pour les erreurs
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF212121);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF424242);

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: backgroundLight,
    cardTheme: const CardTheme(
      color: cardLight,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: successColor,
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: successColor,
    ),
  );
}
