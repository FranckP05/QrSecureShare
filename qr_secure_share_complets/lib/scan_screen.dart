import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/rsa_helper.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

// Écran pour scanner ou afficher des QR codes
class ScanScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ScanScreen({super.key, required this.onToggleTheme});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool showQrCode = false;
  String publicKey = "example-public-key-123";
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _requestCameraPermission();
    }
  }

  // Demande la permission d'accès à la caméra
  Future<void> _requestCameraPermission() async {
    if (kIsWeb) {
      setState(() {
        _hasCameraPermission = false;
      });
      return;
    }
    var status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasCameraPermission = true;
      });
    } else {
      var result = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = result.isGranted;
      });
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('L’accès à la caméra est requis pour scanner un QR code.'),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    }
  }

  // Gère la création de la vue QR
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (scanData.code != null) {
        try {
          // Déchiffre les données
          final decryptedData = await RSAHelper.decryptData(scanData.code!);
          final now = DateTime.now().toIso8601String();

          // Traite les données déchiffrées
          if (decryptedData.startsWith('LINK:')) {
            final url = decryptedData.substring(5);
            final sharedLink = SharedLink(url: url, createdAt: now);
            await DatabaseHelper.instance.insertLink(sharedLink);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lien scanné : $url'),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          } else if (decryptedData.startsWith('PASSWORD:')) {
            final password = decryptedData.substring(9);
            final sharedPassword =
                SharedPassword(password: password, createdAt: now);
            await DatabaseHelper.instance.insertPassword(sharedPassword);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mot de passe scanné'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          } else if (decryptedData.startsWith('WIFI:')) {
            final wifiString = decryptedData.substring(5);
            final ssidMatch = RegExp(r'S:([^;]+);').firstMatch(wifiString);
            final passwordMatch = RegExp(r'P:([^;]+);').firstMatch(wifiString);
            if (ssidMatch != null && passwordMatch != null) {
              final ssid = ssidMatch.group(1)!;
              final password = passwordMatch.group(1)!;
              final sharedWifi =
                  SharedWifi(ssid: ssid, password: password, createdAt: now);
              await DatabaseHelper.instance.insertWifi(sharedWifi);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wi-Fi scanné : $ssid'),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            }
          } else if (decryptedData.startsWith('FILE:')) {
            final filePath = decryptedData.substring(5);
            final sharedFile = SharedFile(
              path: filePath,
              name: path.basename(filePath),
              createdAt: now,
            );
            await DatabaseHelper.instance.insertFile(sharedFile);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fichier scanné : ${sharedFile.name}'),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Type de données non reconnu'),
                backgroundColor: Color(0xFFF44336),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du déchiffrement : $e'),
              backgroundColor: const Color(0xFFF44336),
            ),
          );
        }
      }

      // Pause la caméra après le scan
      controller.pauseCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clé publique'),
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
            if (!showQrCode) ...[
              Text(
                'Scanner une clé publique',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              if (kIsWeb) ...[
                Container(
                  height: 400,
                  child: const Center(
                    child: Text(
                      'Le scan de QR code n’est pas disponible sur le web.',
                      style: TextStyle(fontSize: 18, color: Color(0xFFF44336)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else if (_hasCameraPermission) ...[
                Container(
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: const Color(0xFF1E88E5),
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 300,
                        ),
                      ),
                      if (result != null)
                        Positioned(
                          bottom: 50,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Text(
                              'Résultat : ${result!.code}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: result!.code!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Données copiées : ${result!.code}'),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.copy),
                        label: const Text('Copier'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            result = null;
                            controller?.resumeCamera();
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.redo),
                        label: const Text('Scanner à nouveau'),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                Container(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Permission de caméra requise',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFFF44336)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _requestCameraPermission,
                          icon: const FaIcon(FontAwesomeIcons.camera),
                          label: const Text('Demander la permission'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            if (showQrCode) ...[
              Text(
                'Votre clé publique',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Center(
                child: QrImageView(
                  data: publicKey,
                  version: QrVersions.auto,
                  size: 300.0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Montrez ce QR code à un autre utilisateur pour qu’il le scanne.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showQrCode = !showQrCode;
                  result = null;
                });
                if (showQrCode) {
                  controller?.pauseCamera();
                } else if (_hasCameraPermission && !kIsWeb) {
                  controller?.resumeCamera();
                }
              },
              icon: FaIcon(showQrCode
                  ? FontAwesomeIcons.qrcode
                  : FontAwesomeIcons.share),
              label: Text(
                showQrCode ? 'Revenir au scan' : 'Afficher ma clé publique',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
