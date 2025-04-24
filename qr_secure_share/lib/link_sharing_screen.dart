import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_secure_share/api_helper.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/public_key_management_screen.dart';
import 'package:qr_secure_share/rsa_helper.dart';
import 'package:qr_secure_share/scan_screen.dart';
import 'package:pointycastle/asymmetric/api.dart';

class LinkSharingScreen extends StatefulWidget {
  const LinkSharingScreen({super.key});

  @override
  State<LinkSharingScreen> createState() => _LinkSharingScreenState();
}

class _LinkSharingScreenState extends State<LinkSharingScreen> {
  final TextEditingController _linkController = TextEditingController();
  String? _qrData;
  bool _isLoading = false;
  RSAPublicKey? _recipientPublicKey;
  String? _selectedKeyName;

  // Vérifie le lien et génère le QR code
  Future<void> _shareLink() async {
    if (_recipientPublicKey == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Veuillez sélectionner ou scanner une clé publique')),
        );
      }
      return;
    }

    final link = _linkController.text.trim();
    if (link.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un lien')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Vérifie si le lien est sûr
    final isSafe = await ApiHelper.isLinkSafe(link);
    if (!isSafe) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ce lien est potentiellement dangereux !')),
        );
      }
      return;
    }

    try {
      // Chiffre le lien avec AES et RSA
      final encryptedData = await RSAHelper.encryptDataWithAESAndRSA(
          'LINK:$link', _recipientPublicKey!);

      // Combine les données chiffrées dans un format JSON pour le QR code
      final qrData = {
        'type': 'LINK',
        'encryptedText': encryptedData['encryptedText'],
        'encryptedAESKey': encryptedData['encryptedAESKey'],
        'iv': encryptedData['iv'],
      };
      final qrDataString = jsonEncode(qrData);

      // Sauvegarde dans l'historique
      await DatabaseHelper.instance.insertLink(SharedLink(
        link: link,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chiffrement : $e')),
        );
      }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clé publique scannée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erreur lors de la récupération de la clé publique : $e')),
          );
        }
      }
    }
  }

  // Sélectionne une clé publique existante
  Future<void> _selectPublicKey() async {
    final publicKeys = await DatabaseHelper.instance.getPublicKeys();
    if (publicKeys.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune clé publique enregistrée')),
        );
      }
      return;
    }

    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager un lien'),
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
                'Partager un lien via QR Code',
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
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Entrez le lien',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _shareLink,
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
                      'Scannez ce QR Code pour partager le lien',
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
    _linkController.dispose();
    super.dispose();
  }
}
