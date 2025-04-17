import 'package:flutter/material.dart';
import 'package:secure_share/widgets/gradient_button.dart';
import '../widgets/theme_toggle_button.dart';

class ReceivePage extends StatelessWidget {
  ReceivePage({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [ThemeToggleButton(toggleTheme: toggleTheme)],
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFEDF2FF)
                : Colors.black,
        toolbarHeight: 40,
      ),
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFEDF2FF)
              : Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Réception Sécurisée',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  children: [
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/receive_link.svg',
                      svgWidth: 35,
                      text: 'Recevoir un lien',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/receive_pwd.svg',
                      svgWidth: 40,
                      text: 'Recevoir un mot \nde passe',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [ Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/connect_wifi.svg',
                      svgWidth: 40,
                      text: 'Recevoir un code \nWI-FI',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/download-file.svg',
                      svgWidth: 40,
                      svgColor: Colors.white,
                      text: 'Recevoir un fichier',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
