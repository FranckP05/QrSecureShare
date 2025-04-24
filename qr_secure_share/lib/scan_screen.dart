import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/link_reception_screen.dart';
import 'package:qr_secure_share/rsa_helper.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? _qrData;
  bool _isSharingPublicKey = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Gère les résultats du scan
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        final data = scanData.code!;
        if (_isSharingPublicKey) {
          // Si on est en mode partage de clé publique, ignore les scans
          return;
        }

        // Pause le scan pour éviter plusieurs lectures
        controller.pauseCamera();

        if (data.startsWith('PUBLIC_KEY:')) {
          // Retourne la clé publique scannée
          Navigator.pop(context, data);
          return;
        }

        try {
          // Analyse le JSON du QR code
          final qrData = jsonDecode(data);
          final type = qrData['type'] as String;
          final encryptedText = qrData['encryptedText'] as String;
          final encryptedAESKey = qrData['encryptedAESKey'] as String;
          final iv = qrData['iv'] as String;

          // Déchiffre les données
          final decryptedText = await RSAHelper.decryptDataWithAESAndRSA(
            encryptedText: encryptedText,
            encryptedAESKey: encryptedAESKey,
            iv: iv,
          );

          if (type == 'LINK' && decryptedText.startsWith('LINK:')) {
            final link = decryptedText.substring('LINK:'.length);
            await DatabaseHelper.instance.insertLink(SharedLink(
              link: link,
              createdAt: DateTime.now().toIso8601String(),
            ));
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LinkReceptionScreen(link: link),
                ),
              );
            }
          } else if (type == 'PASSWORD' &&
              decryptedText.startsWith('PASSWORD:')) {
            final password = decryptedText.substring('PASSWORD:'.length);
            await DatabaseHelper.instance.insertPassword(SharedPassword(
              password: password,
              createdAt: DateTime.now().toIso8601String(),
            ));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mot de passe reçu : $password')),
              );
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Type de données inconnu')),
              );
              controller.resumeCamera();
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur lors du déchiffrement : $e')),
            );
            controller.resumeCamera();
          }
        }
      }
    });
  }

  // Vérifie et demande la permission pour la caméra
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission de caméra refusée')),
      );
      Navigator.pop(context);
    }
  }

  // Active/désactive le mode de partage de la clé publique
  void _togglePublicKeySharing() async {
    final keyPair =
        await RSAHelper.getKeyPair(); // Assure que les clés sont générées
    setState(() {
      _isSharingPublicKey = !_isSharingPublicKey;
      _qrData = _isSharingPublicKey
          ? 'PUBLIC_KEY:${RSAHelper.publicKeyToBase64(keyPair.publicKey)}'
          : null;
      if (_isSharingPublicKey) {
        controller?.pauseCamera();
      } else {
        controller?.resumeCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _togglePublicKeySharing,
                    icon: const FaIcon(FontAwesomeIcons.key),
                    label: Text(_isSharingPublicKey
                        ? 'Arrêter le partage de la clé'
                        : 'Partager ma clé publique'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (_isSharingPublicKey && _qrData != null) ...[
                    const SizedBox(height: 10),
                    QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 100.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }
}
