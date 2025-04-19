import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/file_preview_screen.dart';
import 'package:qr_secure_share/file_history_screen.dart';
import 'package:qr_secure_share/rsa_helper.dart';
import 'package:path/path.dart' as path;

// Écran pour partager des fichiers
class FileSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const FileSharingScreen({super.key, required this.onToggleTheme});

  @override
  _FileSharingScreenState createState() => _FileSharingScreenState();
}

class _FileSharingScreenState extends State<FileSharingScreen> {
  File? _selectedFile;
  bool _isLoading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier : $e'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
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

  // Affiche un QR code pour partager le fichier
  Future<void> _showQrCodeDialog(String filePath) async {
    final dataToEncrypt = 'FILE:$filePath';
    final encryptedData = await RSAHelper.encryptData(dataToEncrypt);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code pour partager le fichier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: encryptedData,
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
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const FaIcon(FontAwesomeIcons.fileUpload),
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Fichier partagé : ${path.basename(_selectedFile!.path)}'),
                                  backgroundColor: const Color(0xFF4CAF50),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur lors du partage : $e'),
                                  backgroundColor: const Color(0xFFF44336),
                                ),
                              );
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
              icon: const FaIcon(FontAwesomeIcons.history),
              label: const Text('Voir l’historique',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
