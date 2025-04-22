// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomeScreen extends StatefulWidget {
//   final VoidCallback onToggleTheme;

//   const HomeScreen({super.key, required this.onToggleTheme});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkInstructions();
//   }

//   // Vérifie si l'utilisateur a déjà vu les instructions
//   Future<void> _checkInstructions() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool hasSeen = prefs.getBool('seenHomeInstructions') ?? false;
//     if (!hasSeen) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showInstructionsDialog();
//         prefs.setBool('seenHomeInstructions', true);
//       });
//     }
//   }

//   // Affiche les instructions dans une boîte de dialogue
//   void _showInstructionsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Bienvenue dans QR Secure Share'),
//         content: const Text(
//           'Cette application vous permet de partager des données sécurisées hors ligne :\n'
//           '- Partagez des liens, mots de passe, ou identifiants Wi-Fi via QR code.\n'
//           '- Scannez des QR codes pour recevoir des données.\n'
//           '- Partagez et prévisualisez des fichiers localement.\n'
//           'Sélectionnez une option ci-dessous pour commencer.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK', style: TextStyle(color: Color(0xFF1E88E5))),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Secure Share'),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 1,
//         actions: [
//           IconButton(
//             icon: Icon(
//               Theme.of(context).brightness == Brightness.dark
//                   ? Icons.light_mode
//                   : Icons.dark_mode,
//             ),
//             onPressed: widget.onToggleTheme,
//             tooltip: 'Basculer le thème',
//           ),
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: _showInstructionsDialog,
//             tooltip: 'Instructions',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Que voulez-vous partager ?',
//               style: Theme.of(context).textTheme.headlineMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/link-sharing');
//                       },
//                       icon: const FaIcon(FontAwesomeIcons.link),
//                       label: const Text('Partager un lien',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/link-reception');
//                       },
//                       icon: const FaIcon(FontAwesomeIcons.qrcode),
//                       label: const Text('Recevoir une clé publique',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/password-sharing');
//                       },
//                       icon: const FaIcon(FontAwesomeIcons.key),
//                       label: const Text('Partager un mot de passe',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/wifi-sharing');
//                       },
//                       icon: const FaIcon(FontAwesomeIcons.wifi),
//                       label: const Text('Partager un Wi-Fi',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/file-sharing');
//                       },
//                       icon: const FaIcon(FontAwesomeIcons.file),
//                       label: const Text('Partager un fichier',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
