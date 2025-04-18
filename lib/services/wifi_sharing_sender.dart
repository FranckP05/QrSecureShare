// import 'dart:convert';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:pointycastle/asn1.dart';
// import 'package:pointycastle/api.dart';
// import 'package:pointycastle/asymmetric/api.dart';

// class WifiSharingSender {
//   Future<void> startSharingProcess(BuildContext context) async {
//     // Step 1: Ask user to activate hotspot
//     final hotspotActivated = await _askToEnableHotspot(context);
//     if (!hotspotActivated) return;

//     // Step 2: Ask for hotspot password
//     final password = await _getHotspotPassword(context);
//     if (password == null || password.isEmpty) return;

//     // Step 3: Generate AES key and encrypt password
//     final aesKey = encrypt.Key.fromSecureRandom(32); // 256-bit AES
//     final iv = encrypt.IV.fromLength(16);
//     final aes = encrypt.Encrypter(encrypt.AES(aesKey));
//     final encryptedPassword = aes.encrypt(password, iv: iv);

//     // Step 4: Scan receiver’s RSA public key
//     final publicKeyString = await _simulateScanPublicKey(context);
//     if (publicKeyString == null) return;

//     // Step 5: Encrypt AES key with RSA
//     final rsaPublicKey = _parseRSAPublicKey(publicKeyString);
//     if (rsaPublicKey == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid RSA public key'),
//           backgroundColor: Colors.redAccent,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//     final rsa = encrypt.Encrypter(encrypt.RSA(publicKey: rsaPublicKey));
//     final encryptedAESKey = rsa.encrypt(aesKey.base64);

//     // Step 6: Generate final payload
//     final payload = jsonEncode({
//       'key': encryptedAESKey.base64,
//       'iv': iv.base64,
//       'data': encryptedPassword.base64,
//     });

//     // Step 7: Display the QR code
//     _showPayloadQR(context, payload);
//   }

//   RSAPublicKey? _parseRSAPublicKey(String publicKeyPem) {
//     try {
//       // Remove PEM headers and newlines
//       final keyData = publicKeyPem
//           .replaceAll('-----BEGIN PUBLIC KEY-----', '')
//           .replaceAll('-----END PUBLIC KEY-----', '')
//           .replaceAll('\n', '')
//           .trim();

//       // Decode Base64
//       final keyBytes = base64Decode(keyData);

//       // Parse ASN.1 structure
//       final parser = ASN1Parser(keyBytes);
//       final topLevelSeq = parser.nextObject() as ASN1Sequence;
//       final publicKeySeq = topLevelSeq.elements[1] as ASN1BitString;
//       final publicKeyBytes = publicKeySeq.valueBytes!;

//       // Parse the public key bit string
//       final publicKeyParser = ASN1Parser(publicKeyBytes);
//       final publicKeySeqInner = publicKeyParser.nextObject() as ASN1Sequence;
//       final modulus = publicKeySeqInner.elements[0] as ASN1Integer;
//       final exponent = publicKeySeqInner.elements[1] as ASN1Integer;

//       // Create RSAPublicKey
//       return RSAPublicKey(
//         modulus.integer!,
//         exponent.integer!,
//       );
//     } catch (e) {
//       print('Error parsing RSA public key: $e');
//       return null;
//     }
//   }

//   Future<bool> _askToEnableHotspot(BuildContext context) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Activer le point d\'accès'),
//         content: const Text('Veuillez activer votre point d\'accès avant de continuer.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Annuler'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Activé'),
//           ),
//         ],
//       ),
//     );
//     return result ?? false;
//   }

//   Future<String?> _getHotspotPassword(BuildContext context) async {
//     final controller = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Entrer le mot de passe Wi-Fi'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Mot de passe du hotspot',
//           ),
//           obscureText: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     return controller.text.trim().isEmpty ? null : controller.text.trim();
//   }

//   Future<String?> _simulateScanPublicKey(BuildContext context) async {
//     // ⚠️ Replace with real QR code scanner later
//     final controller = TextEditingController();
//     controller.text = '''
// -----BEGIN PUBLIC KEY-----
// MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtestRSAPUBLICKEYExample==
// -----END PUBLIC KEY-----
// ''';

//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Scanner la clé publique du destinataire'),
//         content: TextField(
//           controller: controller,
//           maxLines: 6,
//           decoration: const InputDecoration(
//             labelText: 'Clé publique (PEM format)',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     return controller.text.trim().isEmpty ? null : controller.text.trim();
//   }

//   void _showPayloadQR(BuildContext context, String payload) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Code à scanner'),
//         content: SizedBox(
//           width: 250,
//           height: 250,
//           child: Center(
//             child: QrImageView(
//               data: payload,
//               version: QrVersions.auto,
//               size: 220.0,
//               backgroundColor: Colors.white,
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Fermer'),
//           ),
//         ],
//       ),
//     );
//   }
// }