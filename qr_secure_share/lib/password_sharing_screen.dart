import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:intl/intl.dart';

// Écran pour partager des mots de passe
class PasswordSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const PasswordSharingScreen({super.key, required this.onToggleTheme});

  @override
  _PasswordSharingScreenState createState() => _PasswordSharingScreenState();
}

class _PasswordSharingScreenState extends State<PasswordSharingScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  List<SharedPassword> _passwordHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Charge l'historique des mots de passe depuis SQLite
  Future<void> _loadHistory() async {
    final passwords = await DatabaseHelper.instance.getPasswords();
    setState(() {
      _passwordHistory = passwords;
    });
  }

  // Sauvegarde un mot de passe dans SQLite
  Future<void> _savePassword(String password) async {
    final sharedPassword = SharedPassword(
      password: password,
      createdAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertPassword(sharedPassword);
    await _loadHistory();
  }

  // Supprime un mot de passe spécifique
  Future<void> _deletePassword(int id) async {
    await DatabaseHelper.instance.deletePassword(id);
    await _loadHistory();
  }

  // Supprime tout l'historique
  Future<void> _clearHistory() async {
    await DatabaseHelper.instance.clearPasswords();
    await _loadHistory();
  }

  // Affiche un QR code pour partager le mot de passe
  void _showQrCodeDialog(String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code pour partager le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: password,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 10),
            Text(
              'Scannez ce QR code pour récupérer le mot de passe.',
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage de mot de passe'),
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
              'Partager un mot de passe',
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
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Entrez le mot de passe',
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
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () async {
                      final password = _passwordController.text.trim();
                      if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer un mot de passe'),
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

                      // Sauvegarde le mot de passe et affiche le QR code
                      await _savePassword(password);
                      _showQrCodeDialog(password);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe partagé'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
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
                              'Historique des mots de passe',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Row(
                              children: [
                                if (_passwordHistory.isNotEmpty)
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
                          child: _passwordHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'Aucun mot de passe partagé',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _passwordHistory.length,
                                  itemBuilder: (context, index) {
                                    final password = _passwordHistory[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                          password.password,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          'Partagé le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(password.createdAt))}',
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
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text:
                                                            password.password));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Mot de passe copié'),
                                                    backgroundColor:
                                                        const Color(0xFF4CAF50),
                                                  ),
                                                );
                                              },
                                              tooltip: 'Copier le mot de passe',
                                            ),
                                            IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.trash,
                                                color: Color(0xFFF44336),
                                              ),
                                              onPressed: () async {
                                                await _deletePassword(
                                                    password.id!);
                                              },
                                              tooltip:
                                                  'Supprimer le mot de passe',
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
