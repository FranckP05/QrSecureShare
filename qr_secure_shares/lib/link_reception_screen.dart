import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Je commente l'import ci-dessous par ce que je me suis rendu compte que Flutlab ne me permet pas d'utiliser l'option Bluetooth en ligne et kIsWeb n'est pas utilisé tant que le Bluetooth est désactivé
// import 'package:flutter/foundation.dart' show kIsWeb;

class LinkReceptionScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LinkReceptionScreen({super.key, required this.onToggleTheme});

  @override
  _LinkReceptionScreenState createState() => _LinkReceptionScreenState();
}

class _LinkReceptionScreenState extends State<LinkReceptionScreen> {
  bool _isLoading = false;
  // Pareil que mon commentaire plus haut, et c'est une variable de la bibliothèque qui n'est pas utilisée tant que le Bluetooth est désactivé
  // bool _isBluetoothEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkInstructions();
  }

  // a ce niveau, je Vérifie si l'utilisateur a déjà vu les instructions
  void _checkInstructions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('seenLinkReceptionInstructions') ?? false;
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionsDialog();
        prefs.setBool('seenLinkReceptionInstructions', true);
      });
    }
  }

  // maintenat, j'affiche les instructions dans une boîte de dialogue
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recevoir un lien'),
        content: const Text(
          '1. Appuyez sur "Scanner la clé publique" pour scanner un QR code.\n'
          '2. Ou sélectionnez "Recevoir via Bluetooth" pour recevoir directement.\n'
          '3. Une fois reçu, le lien sera décrypté et affiché.',
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

  // Je fais un exemple pour la reception des données via Bluetooth (c'est juste un exemple car je vais integrer la fonctionnalite lorsque je vais commencer avec le backend)
  Future<void> _receiveViaBluetooth() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Le Bluetooth est désactivé temporairement dans FlutLab.'),
        backgroundColor: Color(0xFFF44336),
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réception sécurisée'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructionsDialog,
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
                        : ElevatedButton.icon(
                            onPressed: _receiveViaBluetooth,
                            icon: const FaIcon(FontAwesomeIcons.bluetooth),
                            label: const Text('Recevoir via Bluetooth',
                                style: TextStyle(fontSize: 16)),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notification indiquant de décryptage du fichier',
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
