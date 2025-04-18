import 'package:flutter/material.dart';

class ThemeToggleButton extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ThemeToggleButton({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: toggleTheme,
      icon: Icon(
        Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF023599) : const Color(0xFFD1E3FF),
      ),
    );
  }
}