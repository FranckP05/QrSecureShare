import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/public_key_management_screen.dart';
import 'package:qr_secure_share/rsa_helper.dart';
import 'package:qr_secure_share/scan_screen.dart';
import 'package:pointycastle/asymmetric/api.dart';

class PasswordSharingScreen extends StatefulWidget {
  const PasswordSharingScreen({super.key});

  @override
  _PasswordSharingScreenState createState() => _PasswordSharingScreenState();
}

class _PasswordSharingScreenState extends State<PasswordSharingScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _qrData;
  bool _isLoading = false;
  RSAPublicKey? _recipientPublicKey;
  String? _selectedKeyName;

  // Génère le QR code avec le mot de passe chiffré
  Future<void> _sharePassword() async {
    if (_recipientPublicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner ou scanner une clé publique')),
      );
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un mot de passe')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chiffre le mot de passe avec AES et RSA
      final encryptedData = await RSAHelper.encryptDataWithAESAndRSA(
          'PASSWORD:$password', _recipientPublicKey!);

      // Combine les données chiffrées dans un format JSON pour le QR code
      final qrData = {
        'type': 'PASSWORD',
        'encryptedText': encryptedData['encryptedText'],
        'encryptedAESKey': encryptedData['encryptedAESKey'],
        'iv': encryptedData['iv'],
      };
      final qrDataString = jsonEncode(qrData);

      // Sauvegarde dans l'historique
      await DatabaseHelper.instance.insertPassword(SharedPassword(
        password: password,
        createdAt: DateTime.now().toIso8601String(),
      ));

      setState(() {
        _qrData = qrDataString;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chiffrement : $e')),
      );
    }
  }

  // Scanne une nouvelle clé publique
  Future<void> _scanPublicKey() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );

    if (result != null &&
        result is String &&
        result.startsWith('PUBLIC_KEY:')) {
      final publicKeyBase64 = result.substring('PUBLIC_KEY:'.length);
      try {
        _recipientPublicKey = RSAHelper.publicKeyFromBase64(publicKeyBase64);
        _selectedKeyName = 'Clé scannée';
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clé publique scannée avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la récupération de la clé publique : $e')),
        );
      }
    }
  }

  // Sélectionne une clé publique existante
  Future<void> _selectPublicKey() async {
    final publicKeys = await DatabaseHelper.instance.getPublicKeys();
    if (publicKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune clé publique enregistrée')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sélectionner une clé publique'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: publicKeys.length,
              itemBuilder: (context, index) {
                final key = publicKeys[index];
                return ListTile(
                  title: Text(key.name),
                  subtitle: Text('Ajoutée le ${key.createdAt}'),
                  onTap: () {
                    _recipientPublicKey =
                        RSAHelper.publicKeyFromBase64(key.keyBase64);
                    _selectedKeyName = key.name;
                    setState(() {});
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager un mot de passe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PublicKeyManagementScreen()),
              );
            },
            tooltip: 'Gérer les clés publiques',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Partager un mot de passe via QR Code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectPublicKey,
                      icon: const Icon(Icons.vpn_key),
                      label: const Text('Choisir une clé publique'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _scanPublicKey,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedKeyName != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Clé sélectionnée : $_selectedKeyName',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Entrez le mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _sharePassword,
                icon: const FaIcon(FontAwesomeIcons.qrcode),
                label: Text(_isLoading ? 'Chargement...' : 'Générer QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_qrData != null)
                Column(
                  children: [
                    Center(
                      child: QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Scannez ce QR Code pour partager le mot de passe',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
