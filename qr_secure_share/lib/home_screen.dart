import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  // Affiche les instructions générales dans une boîte de dialogue
  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutoriel - QR Secure Share'),
        content: const Text(
          'Bienvenue dans QR Secure Share ! Voici comment utiliser l’application :\n\n'
          '1. **Partager un lien** : Entrez un lien, analysez-le, et partagez-le via QR code ou Bluetooth.\n'
          '2. **Recevoir un lien** : Scannez un QR code ou recevez un lien via Bluetooth.\n'
          '3. **Partager un mot de passe** : Entrez un mot de passe et générez un QR code pour le partager.\n'
          '4. **Partager un code Wi-Fi** : Entrez les informations de votre Wi-Fi et générez un QR code.\n\n'
          'Appuyez sur le bouton "?" sur chaque page pour des instructions spécifiques.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Secure Share'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showTutorialDialog(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/link-sharing');
                        },
                        icon: const FaIcon(FontAwesomeIcons.link),
                        label: const Text('Partager un lien'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/link-reception');
                        },
                        icon: const FaIcon(FontAwesomeIcons.download),
                        label: const Text('Recevoir un lien'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/password-sharing');
                        },
                        icon: const FaIcon(FontAwesomeIcons.key),
                        label: const Text('Partager un mot de passe'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/wifi-sharing');
                        },
                        icon: const FaIcon(FontAwesomeIcons.wifi),
                        label: const Text('Partager un code Wi-Fi'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showTutorialDialog(context),
                icon: const FaIcon(FontAwesomeIcons.book),
                label: const Text('Voir le tutoriel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
