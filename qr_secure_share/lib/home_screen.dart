import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/file_history_screen.dart';
import 'package:qr_secure_share/file_sharing_screen.dart';
import 'package:qr_secure_share/link_sharing_screen.dart';
import 'package:qr_secure_share/password_sharing_screen.dart';
import 'package:qr_secure_share/public_key_management_screen.dart';
import 'package:qr_secure_share/scan_screen.dart';
import 'package:qr_secure_share/wifi_sharing_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Secure Share'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: onToggleTheme,
            tooltip: 'Basculer le thème',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue dans QR Secure Share',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.link,
                    title: 'Partager un lien',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LinkSharingScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.lock,
                    title: 'Partager un mot de passe',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PasswordSharingScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.wifi,
                    title: 'Partager un Wi-Fi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WifiSharingScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.file,
                    title: 'Partager un fichier',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FileSharingScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.qrcode,
                    title: 'Scanner un QR Code',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScanScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: 'Historique des fichiers',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FileHistoryScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    icon: FontAwesomeIcons.key,
                    title: 'Gérer les clés publiques',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PublicKeyManagementScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 40,
                color: const Color(0xFF1E88E5),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
