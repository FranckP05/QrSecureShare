import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LinkSharingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LinkSharingScreen({super.key, required this.onToggleTheme});

  @override
  _LinkSharingScreenState createState() => _LinkSharingScreenState();
}

class _LinkSharingScreenState extends State<LinkSharingScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;
  List<String> _linkHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _checkInstructions();
  }

  // Vérifie si l'utilisateur a déjà vu les instructions
  void _checkInstructions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeen = prefs.getBool('seenLinkSharingInstructions') ?? false;
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionsDialog();
        prefs.setBool('seenLinkSharingInstructions', true);
      });
    }
  }

  // Affiche les instructions dans une boîte de dialogue
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager un lien'),
        content: const Text(
          '1. Entrez un lien dans le champ ci-dessous.\n'
          '2. Appuyez sur "Analyser et partager" pour vérifier sa validité.\n'
          '3. Une fois vérifié, le lien sera partagé via Bluetooth ou QR code.',
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

  // Charge l'historique des liens depuis SharedPreferences
  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkHistory = prefs.getStringList('linkHistory') ?? [];
      print('Historique chargé : $_linkHistory'); // Pour déboguer
    });
  }

  // Sauvegarde un lien dans l'historique
  void _saveLink(String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _linkHistory.insert(0, link);
    if (_linkHistory.length > 10) _linkHistory = _linkHistory.sublist(0, 10);
    await prefs.setStringList('linkHistory', _linkHistory);
    print('Lien sauvegardé : $link'); // Pour déboguer
    print('Nouvel historique : $_linkHistory'); // Pour déboguer
    setState(() {});
  }

  // Supprime un lien spécifique de l'historique
  void _deleteLink(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkHistory.removeAt(index);
    });
    await prefs.setStringList('linkHistory', _linkHistory);
  }

  // Supprime tout l'historique
  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkHistory.clear();
    });
    await prefs.setStringList('linkHistory', _linkHistory);
  }

  // Valide si le lien est une URL correcte en utilisant une expression régulière
  bool _isValidUrl(String url) {
    const urlPattern = r'^(https?:\/\/)?' // Protocole (optionnel)
        r'((([a-zA-Z\d]([a-zA-Z\d-]*[a-zA-Z\d])*)\.)+[a-zA-Z]{2,}|' // Domaine
        r'((\d{1,3}\.){3}\d{1,3}))' // Ou adresse IP
        r'(\:\d+)?' // Port (optionnel)
        r'(\/[-a-zA-Z\d%_.~+]*)*' // Chemin
        r'(\?[;&a-zA-Z\d%_.~+=-]*)?' // Paramètres de requête
        r'(\#[-a-zA-Z\d_]*)?$'; // Fragment
    final RegExp regex = RegExp(urlPattern);
    return regex.hasMatch(url) &&
        (url.startsWith('http://') || url.startsWith('https://'));
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
                      if (_linkController.text.isNotEmpty) {
                        if (_isValidUrl(_linkController.text)) {
                          setState(() {
                            _isLoading = true;
                          });

                          // Simuler une analyse (remplacée par une vraie analyse avec backend si nécessaire)
                          await Future.delayed(const Duration(seconds: 2));

                          setState(() {
                            _isLoading = false;
                          });

                          // Avnat que le users ne partage son lien, je lui demander confirmation avant d'envoyer une , pe modifier s'il le souhaite
                          bool? confirmSend = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer l’envoi'),
                              content: Text(
                                'Voulez-vous envoyer ce lien ?\n${_linkController.text}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Effacer et entrer un autre',
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
                            _saveLink(_linkController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Lien prêt à partager : ${_linkController.text}'),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          } else {
                            _linkController.clear();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Veuillez entrer un lien valide (ex. : https://example.com)'),
                              backgroundColor: Color(0xFFF44336),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer un lien'),
                            backgroundColor: Color(0xFFF44336),
                          ),
                        );
                      }
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
                  isDismissible:
                      true, // Je Permet de fermer la boite de dialogue en appuyant à l'extérieur
                  enableDrag:
                      true, // ici je Permet de faire glisser pour fermer avec une animation
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16),
                    height: 400,
                    child: Column(
                      children: [
                        // Je met une barre de saisie (drag handle)
                        Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
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
                                    onPressed: () {
                                      _clearHistory();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Tout supprimer',
                                      style:
                                          TextStyle(color: Color(0xFFF44336)),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
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
                                  itemBuilder: (context, index) => Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      title: Text(
                                        _linkHistory[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons
                                                  .arrowUpRightFromSquare,
                                              color: Color(0xFF1E88E5),
                                            ),
                                            onPressed: () async {
                                              if (await canLaunchUrl(Uri.parse(
                                                  _linkHistory[index]))) {
                                                await launchUrl(Uri.parse(
                                                    _linkHistory[index]));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Impossible d’ouvrir le lien'),
                                                    backgroundColor:
                                                        Color(0xFFF44336),
                                                  ),
                                                );
                                              }
                                            },
                                            tooltip: 'Ouvrir le lien',
                                          ),
                                          IconButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.copy,
                                              color: Color(0xFF1E88E5),
                                            ),
                                            onPressed: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text:
                                                          _linkHistory[index]));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Lien copié : ${_linkHistory[index]}'),
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
                                            onPressed: () {
                                              _deleteLink(index);
                                            },
                                            tooltip: 'Supprimer le lien',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
            const SizedBox(height: 20),
            Text(
              'Autres options de partage',
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/password-sharing');
                      },
                      icon: const FaIcon(FontAwesomeIcons.key),
                      label: const Text('Partager un mot de passe',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wifi-sharing');
                      },
                      icon: const FaIcon(FontAwesomeIcons.wifi),
                      label: const Text('Partager un code Wi-Fi',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Partage de fichier sélectionné')),
                        );
                      },
                      icon: const FaIcon(FontAwesomeIcons.file),
                      label: const Text('Partager un fichier',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
