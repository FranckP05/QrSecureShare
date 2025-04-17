import 'package:flutter/material.dart';
import 'package:secure_share/widgets/gradient_button.dart';
import '../widgets/theme_toggle_button.dart';

class SharePage extends StatelessWidget {
  SharePage({super.key, required this.toggleTheme});
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
                  'Partage Sécurisée',
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
                      svgPath: 'assets/icons/share_bold.svg',
                      svgWidth: 35,
                      svgColor: Colors.white,
                      text: 'Partager un lien',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/share_square.svg',
                      svgColor: Colors.white,
                      svgWidth: 30,
                      text: 'Partager un mot \nde passe',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/share_wifi.svg',
                      svgWidth: 30,
                      svgColor: Colors.white,
                      text: 'Partager un code \nWI-FI',
                      lightColors: const [Color(0xFF0968e5), Color(0xFF091970)],
                      darkColors: const [Color(0xFF2178dd), Color(0xFF141C86)],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      onPressed: () {},
                      svgPath: 'assets/icons/share_file.svg',
                      svgWidth: 30,
                      svgColor: Colors.white,
                      text: 'Partager un fichier',
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
