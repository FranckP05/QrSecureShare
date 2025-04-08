import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PasswordSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const PasswordSharingScreen({super.key, required this.onToggleTheme});

  @override
  _PasswordSharingScreenState createState() => _PasswordSharingScreenState();
}

class _PasswordSharingScreenState extends State<PasswordSharingScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _qrData;
  bool _isLoading = false;
  bool _showQrCode = false; // Je fais ceci pour contrôler l'animation de l'app

  @override
  void initState() {
    super.initState();
    _checkInstructions();
  }

  // Je vérifie toujours si l'utilisateur a déjà vu les instructions
  void _checkInstructions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('seenPasswordSharingInstructions') ?? false;
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionsDialog();
        prefs.setBool('seenPasswordSharingInstructions', true);
      });
    }
  }

  // Puis j'affiche les instructions dans une boîte de dialogue
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager un mot de passe'),
        content: const Text(
          '1. Entrez le mot de passe que vous souhaitez partager.\n'
          '2. Appuyez sur "Générer le QR code" pour créer un QR code.\n'
          '3. Un autre utilisateur peut scanner ce QR code pour récupérer le mot de passe.',
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

  //Maintenant, apres scan, je génère le QR code pour le mot de passe
  void _generateQrCode() {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un mot de passe'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Et apres, le QR code contiendra simplement le mot de passe
    final passwordData = _passwordController.text;
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _qrData = passwordData;
        _isLoading = false;
        _showQrCode = true; // Je déclenche l'animation au moment du scan
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code généré avec succès'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage de mot de passe'),
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
            Text(
              'Partager un mot de passe',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const FaIcon(
                      FontAwesomeIcons.lock,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  obscureText: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _generateQrCode,
                    icon: const FaIcon(FontAwesomeIcons.qrcode),
                    label: const Text('Générer le QR code',
                        style: TextStyle(fontSize: 16)),
                  ),
            if (_qrData != null) ...[
              const SizedBox(height: 20),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(_showQrCode ? 1.0 : 0.0),
                  child: Opacity(
                    opacity: _showQrCode ? 1.0 : 0.0,
                    child: QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 300.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(10),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF1E88E5),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Scannez ce QR code pour récupérer le mot de passe.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
