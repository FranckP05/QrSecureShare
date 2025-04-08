import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Je fais une mportation sans condition pour pouvoir travailler sans erreur a la suite
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart'; // Je fais pareil que l'autre
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    _checkInstructions();
    if (!kIsWeb) {
      _requestCameraPermission();
    }
  }

  // Toujour, je vérifie si l'utilisateur a déjà vu les instructions
  void _checkInstructions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('seenScanInstructions') ?? false;
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionsDialog();
        prefs.setBool('seenScanInstructions', true);
      });
    }
  }

  // Et ensuite, j'affiche les instructions dans une boîte de dialogue
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanner une clé publique'),
        content: const Text(
          '1. Alignez le QR code dans le carré pour le scanner.\n'
          '2. Une fois scanné, le lien ou la clé sera affiché.\n'
          '3. Appuyez sur "Afficher le code" pour générer votre propre QR code que d’autres peuvent scanner.',
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

  // Je commence par demander la permission d'accès à la caméra pour eviter le hack
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

  //si l'utilisateur choisir l'envoie des données via Bluetooth
  Future<void> _sendViaBluetooth() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Le Bluetooth est désactivé temporairement dans FlutLab.'), // A cause de ma remarque faite dans l'autre fichier avec les mentions du pourquoi        backgroundColor: Color(0xFFF44336),
      ),
    );
    return;
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      // Je fais toujours une demande de confirmation pour envoyer après scan
      bool? confirmSend = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clé scannée'),
          content: Text(
              'Clé scannée : ${scanData.code}\nVoulez-vous envoyer cette clé ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Envoyer',
                style: TextStyle(color: Color(0xFF1E88E5)),
              ),
            ),
          ],
        ),
      );

      if (confirmSend == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clé envoyée : ${scanData.code}'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      } else {
        setState(() {
          result = null;
        });
        controller.resumeCamera();
      }
    });
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir le lien'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    }
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
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(
                              0xFFF44336)), // Toujours par rapport a ma remarque
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
                      ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: result!.code!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lien copié : ${result!.code}'),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        },
                        child: const Text('Copier'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _launchURL(result!.code!);
                        },
                        child: const Text('Ouvrir'),
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
                        ElevatedButton(
                          onPressed: _requestCameraPermission,
                          child: const Text('Demander la permission'),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showQrCode = !showQrCode;
                });
                if (showQrCode) {
                  controller?.pauseCamera();
                } else {
                  controller?.resumeCamera();
                }
              },
              child: Text(
                showQrCode ? 'Revenir au scan' : 'Afficher le code',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            if (!showQrCode)
              ElevatedButton.icon(
                onPressed: _sendViaBluetooth,
                icon: const FaIcon(FontAwesomeIcons.bluetooth),
                label: const Text('Envoyer via Bluetooth',
                    style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
