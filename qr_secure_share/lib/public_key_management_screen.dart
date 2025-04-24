import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_secure_share/database_helper.dart';
import 'package:qr_secure_share/scan_screen.dart';

class PublicKeyManagementScreen extends StatefulWidget {
  const PublicKeyManagementScreen({super.key});

  @override
  _PublicKeyManagementScreenState createState() =>
      _PublicKeyManagementScreenState();
}

class _PublicKeyManagementScreenState extends State<PublicKeyManagementScreen> {
  List<PublicKey> _publicKeys = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPublicKeys();
  }

  // Charge les clés publiques depuis SQLite
  Future<void> _loadPublicKeys() async {
    final keys = await DatabaseHelper.instance.getPublicKeys();
    setState(() {
      _publicKeys = keys;
    });
  }

  // Supprime une clé publique spécifique
  Future<void> _deletePublicKey(int id) async {
    await DatabaseHelper.instance.deletePublicKey(id);
    await _loadPublicKeys();
  }

  // Supprime toutes les clés publiques
  Future<void> _clearPublicKeys() async {
    await DatabaseHelper.instance.clearPublicKeys();
    await _loadPublicKeys();
  }

  // Scanne une nouvelle clé publique et demande un nom
  Future<void> _addPublicKey() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );

    if (result != null &&
        result is String &&
        result.startsWith('PUBLIC_KEY:')) {
      final keyBase64 = result.substring('PUBLIC_KEY:'.length);
      _showNameDialog(keyBase64);
    }
  }

  // Affiche un dialogue pour entrer le nom du correspondant
  void _showNameDialog(String keyBase64) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nom du correspondant'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Entrez un nom',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un nom')),
                  );
                  return;
                }
                await DatabaseHelper.instance.insertPublicKey(PublicKey(
                  name: name,
                  keyBase64: keyBase64,
                  createdAt: DateTime.now().toIso8601String(),
                ));
                _nameController.clear();
                Navigator.pop(context);
                await _loadPublicKeys();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les clés publiques'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clés publiques des correspondants',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (_publicKeys.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await _clearPublicKeys();
                    },
                    child: const Text(
                      'Tout supprimer',
                      style: TextStyle(color: Color(0xFFF44336)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addPublicKey,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Ajouter une clé publique'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _publicKeys.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune clé publique enregistrée',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _publicKeys.length,
                      itemBuilder: (context, index) {
                        final key = _publicKeys[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              key.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Ajoutée le ${key.createdAt}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.trash,
                                color: Color(0xFFF44336),
                              ),
                              onPressed: () async {
                                await _deletePublicKey(key.id!);
                              },
                              tooltip: 'Supprimer la clé',
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
