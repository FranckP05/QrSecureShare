import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:intl/intl.dart';

// Écran pour partager des identifiants Wi-Fi
class WifiSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const WifiSharingScreen({super.key, required this.onToggleTheme});

  @override
  _WifiSharingScreenState createState() => _WifiSharingScreenState();
}

class _WifiSharingScreenState extends State<WifiSharingScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  List<SharedWifi> _wifiHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Charge l'historique des identifiants Wi-Fi depuis SQLite
  Future<void> _loadHistory() async {
    final wifi = await DatabaseHelper.instance.getWifi();
    setState(() {
      _wifiHistory = wifi;
    });
  }

  // Sauvegarde un identifiant Wi-Fi dans SQLite
  Future<void> _saveWifi(String ssid, String password) async {
    final sharedWifi = SharedWifi(
      ssid: ssid,
      password: password,
      createdAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertWifi(sharedWifi);
    await _loadHistory();
  }

  // Supprime un identifiant Wi-Fi spécifique
  Future<void> _deleteWifi(int id) async {
    await DatabaseHelper.instance.deleteWifi(id);
    await _loadHistory();
  }

  // Supprime tout l'historique
  Future<void> _clearHistory() async {
    await DatabaseHelper.instance.clearWifi();
    await _loadHistory();
  }

  // Génère une chaîne au format Wi-Fi pour le QR code
  String _generateWifiString(String ssid, String password) {
    return 'WIFI:T:WPA;S:$ssid;P:$password;;';
  }

  // Affiche un QR code pour partager l'identifiant Wi-Fi
  void _showQrCodeDialog(String wifiString) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code pour partager le Wi-Fi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: wifiString,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 10),
            Text(
              'Scannez ce QR code pour se connecter au Wi-Fi.',
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
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage de Wi-Fi'),
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
              'Partager un Wi-Fi',
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
                    TextField(
                      controller: _ssidController,
                      decoration: InputDecoration(
                        labelText: 'Nom du réseau (SSID)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const FaIcon(
                          FontAwesomeIcons.wifi,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const FaIcon(
                          FontAwesomeIcons.key,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () async {
                      final ssid = _ssidController.text.trim();
                      final password = _passwordController.text.trim();
                      if (ssid.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez remplir tous les champs'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      // Simule une analyse
                      await Future.delayed(const Duration(seconds: 1));

                      setState(() {
                        _isLoading = false;
                      });

                      // Sauvegarde l'identifiant Wi-Fi et affiche le QR code
                      final wifiString = _generateWifiString(ssid, password);
                      await _saveWifi(ssid, password);
                      _showQrCodeDialog(wifiString);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Identifiant Wi-Fi partagé'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                      _ssidController.clear();
                      _passwordController.clear();
                    },
                    icon: const FaIcon(FontAwesomeIcons.share),
                    label:
                        const Text('Partager', style: TextStyle(fontSize: 16)),
                  ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isDismissible: true,
                  enableDrag: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16),
                    height: 400,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Historique des Wi-Fi',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Row(
                              children: [
                                if (_wifiHistory.isNotEmpty)
                                  TextButton(
                                    onPressed: () async {
                                      await _clearHistory();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Tout supprimer',
                                      style:
                                          TextStyle(color: Color(0xFFF44336)),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.chevronDown,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  tooltip: 'Fermer l’historique',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _wifiHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'Aucun Wi-Fi partagé',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _wifiHistory.length,
                                  itemBuilder: (context, index) {
                                    final wifi = _wifiHistory[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                          wifi.ssid,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          'Partagé le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(wifi.createdAt))}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.copy,
                                                color: Color(0xFF1E88E5),
                                              ),
                                              onPressed: () async {
                                                final wifiString =
                                                    _generateWifiString(
                                                        wifi.ssid,
                                                        wifi.password);
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text: wifiString));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Identifiant Wi-Fi copié'),
                                                    backgroundColor:
                                                        const Color(0xFF4CAF50),
                                                  ),
                                                );
                                              },
                                              tooltip:
                                                  'Copier l’identifiant Wi-Fi',
                                            ),
                                            IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.trash,
                                                color: Color(0xFFF44336),
                                              ),
                                              onPressed: () async {
                                                await _deleteWifi(wifi.id!);
                                              },
                                              tooltip:
                                                  'Supprimer l’identifiant Wi-Fi',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
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
