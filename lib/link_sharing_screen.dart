import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secure_share/database/database_helper.dart';
import 'package:intl/intl.dart';

// Écran pour partager des liens avec un historique persistant
class LinkSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LinkSharingScreen({super.key, required this.onToggleTheme});

  @override
  _LinkSharingScreenState createState() => _LinkSharingScreenState();
}

class _LinkSharingScreenState extends State<LinkSharingScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;
  List<SharedLink> _linkHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Charge l'historique des liens depuis SQLite
  Future<void> _loadHistory() async {
    final links = await DatabaseHelper.instance.getLinks();
    setState(() {
      _linkHistory = links;
    });
  }

  // Sauvegarde un lien dans SQLite
  Future<void> _saveLink(String link) async {
    final sharedLink = SharedLink(
      url: link,
      createdAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertLink(sharedLink);
    await _loadHistory(); // Rafraîchit l'historique
  }

  // Supprime un lien spécifique de l'historique
  Future<void> _deleteLink(int id) async {
    await DatabaseHelper.instance.deleteLink(id);
    await _loadHistory();
  }

  // Supprime tout l'historique
  Future<void> _clearHistory() async {
    await DatabaseHelper.instance.clearLinks();
    await _loadHistory();
  }

  // Valide si le lien est une URL correcte
  bool _isValidUrl(String url) {
    const urlPattern = r'^(http?:\/\/)?' // Protocole (optionnel)
        r'((([a-zA-Z\d]([a-zA-Z\d-]*[a-zA-Z\d])*)\.)+[a-zA-Z]{2,}|' // Domaine
        r'((\d{1,3}\.){3}\d{1,3}))' // Ou adresse IP
        r'(\:\d+)?' // Port (optionnel)
        r'(\/[-a-zA-Z\d%_.~+]*)*' // Chemin
        r'(\?[;&a-zA-Z\d%_.~+=-]*)?' // Paramètres de requête
        r'(\#[-a-zA-Z\d_]*)?$'; // Fragment
    final RegExp regex = RegExp(urlPattern);
    return regex.hasMatch(url) &&
        (url.startsWith('https://') || url.startsWith('https://'));
  }

  // Affiche un QR code pour partager le lien
  void _showQrCodeDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code pour partager le lien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 10),
            Text(
              'Scannez ce QR code pour récupérer le lien.',
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
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage sécurisé'),
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
              'Partager un lien',
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
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre lien',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const FaIcon(
                      FontAwesomeIcons.link,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () async {
                      final url = _linkController.text.trim();
                      if (url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer un lien'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                        return;
                      }
                      if (!_isValidUrl(url)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Veuillez entrer un lien valide (ex. : https://example.com)'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      // Simule une analyse (remplacée par une vérification réelle si nécessaire)
                      await Future.delayed(const Duration(seconds: 1));

                      setState(() {
                        _isLoading = false;
                      });

                      // Sauvegarde le lien et affiche le QR code
                      await _saveLink(url);
                      _showQrCodeDialog(url);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lien partagé : $url'),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                      _linkController.clear();
                    },
                    icon: const FaIcon(FontAwesomeIcons.share),
                    label: const Text('Analyser et partager',
                        style: TextStyle(fontSize: 16)),
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
                              'Historique des liens partagés',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Row(
                              children: [
                                if (_linkHistory.isNotEmpty)
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
                          child: _linkHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'Aucun lien partagé',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _linkHistory.length,
                                  itemBuilder: (context, index) {
                                    final link = _linkHistory[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                          link.url,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          'Partagé le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(link.createdAt))}',
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
                                                        text: link.url));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Lien copié : ${link.url}'),
                                                    backgroundColor:
                                                        const Color(0xFF4CAF50),
                                                  ),
                                                );
                                              },
                                              tooltip: 'Copier le lien',
                                            ),
                                            IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.trash,
                                                color: Color(0xFFF44336),
                                              ),
                                              onPressed: () async {
                                                await _deleteLink(link.id!);
                                              },
                                              tooltip: 'Supprimer le lien',
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
