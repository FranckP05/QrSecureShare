import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Écran pour recevoir des clés publiques via QR code
class LinkReceptionScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LinkReceptionScreen({super.key, required this.onToggleTheme});

  @override
  _LinkReceptionScreenState createState() => _LinkReceptionScreenState();
}

class _LinkReceptionScreenState extends State<LinkReceptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réception sécurisée'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Basculer le thème',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Navigator.pushNamed(context, '/scan');
                      },
                      icon: const FaIcon(FontAwesomeIcons.qrcode),
                      label: const Text('Scanner la clé publique',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scannez un QR code pour recevoir une clé publique.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
