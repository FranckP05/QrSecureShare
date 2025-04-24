import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/file_preview_screen.dart';
import 'package:qr_secure_share/file_history_screen.dart';
import 'package:qr_secure_share/rsa_helper.dart';
import 'package:qr_secure_share/scan_screen.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:path/path.dart' as path;

// Écran pour partager des fichiers
class FileSharingScreen extends StatefulWidget {
  const FileSharingScreen({super.key});

  @override
  State<FileSharingScreen> createState() => _FileSharingScreenState();
}

class _FileSharingScreenState extends State<FileSharingScreen> {
  File? _selectedFile;
  bool _isLoading = false;
  RSAPublicKey? _recipientPublicKey;
  String? _selectedKeyName;

  // Sélectionne un fichier depuis l'appareil
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du fichier : $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  // Sauvegarde le fichier dans SQLite
  Future<void> _saveFileToHistory(File file) async {
    final sharedFile = SharedFile(
      path: file.path,
      name: path.basename(file.path),
      createdAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertFile(sharedFile);
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

  // Affiche un QR code pour partager le fichier
  Future<void> _showQrCodeDialog(String filePath) async {
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

    try {
      final dataToEncrypt = 'FILE:$filePath';
      final encryptedData = await RSAHelper.encryptDataWithAESAndRSA(
          dataToEncrypt, _recipientPublicKey!);

      final qrData = {
        'type': 'FILE',
        'encryptedText': encryptedData['encryptedText'],
        'encryptedAESKey': encryptedData['encryptedAESKey'],
        'iv': encryptedData['iv'],
      };
      final qrDataString = jsonEncode(qrData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('QR Code pour partager le fichier'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: qrDataString,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scannez ce QR code pour récupérer le chemin du fichier.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer',
                    style: TextStyle(color: Color(0xFF1E88E5))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chiffrement : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage de fichiers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Partager un fichier',
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
                child: Column(
                  children: [
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
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const FaIcon(FontAwesomeIcons.fileArrowUp),
                      label: const Text('Sélectionner un fichier',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedFile != null)
                      Column(
                        children: [
                          Text(
                            'Fichier sélectionné : ${path.basename(_selectedFile!.path)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FilePreviewScreen(file: _selectedFile!),
                                ),
                              );
                            },
                            icon: const FaIcon(FontAwesomeIcons.eye),
                            label: const Text('Prévisualiser',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _selectedFile == null
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              // Sauvegarde dans l'historique
                              await _saveFileToHistory(_selectedFile!);

                              // Affiche le QR code avec le chemin du fichier
                              await _showQrCodeDialog(_selectedFile!.path);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Fichier partagé : ${path.basename(_selectedFile!.path)}'),
                                    backgroundColor: const Color(0xFF4CAF50),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Erreur lors du partage : $e'),
                                    backgroundColor: const Color(0xFFF44336),
                                  ),
                                );
                              }
                            }

                            setState(() {
                              _isLoading = false;
                              _selectedFile = null;
                            });
                          },
                    icon: const FaIcon(FontAwesomeIcons.share),
                    label:
                        const Text('Partager', style: TextStyle(fontSize: 16)),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FileHistoryScreen()),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.clockRotateLeft),
              label: const Text('Voir l’historique',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
