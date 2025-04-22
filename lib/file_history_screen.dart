import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secure_share/database/database_helper.dart';
import 'package:secure_share/file_preview_screen.dart';
import 'package:intl/intl.dart';

// Je cree un écran pour afficher l'historique des fichiers partagés
class FileHistoryScreen extends StatefulWidget {
  const FileHistoryScreen({super.key});

  @override
  State<FileHistoryScreen> createState() => _FileHistoryScreenState();
}

class _FileHistoryScreenState extends State<FileHistoryScreen> {
  List<SharedFile> _fileHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Je  charge l'historique des fichiers depuis SQLite
  Future<void> _loadHistory() async {
    final files = await DatabaseHelper.instance.getFiles();
    if (mounted) {
      setState(() {
        _fileHistory = files;
      });
    }
  }

  // Je cherche a supprimer un fichier spécifique de l'historique
  Future<void> _deleteFile(int id) async {
    await DatabaseHelper.instance.deleteFile(id);
    await _loadHistory();
  }

  //Ici, je supprime tout l'historique
  Future<void> _clearHistory() async {
    await DatabaseHelper.instance.clearFiles();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des fichiers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                              'Historique des fichiers partagés',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Row(
                              children: [
                                if (_fileHistory.isNotEmpty)
                                  TextButton(
                                    onPressed: () async {
                                      await _clearHistory();
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
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
                          child: _fileHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'Aucun fichier partagé',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _fileHistory.length,
                                  itemBuilder: (context, index) {
                                    final file = _fileHistory[index];
                                    final fileObj = File(file.path);
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                          file.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          'Partagé le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(file.createdAt))}',
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
                                                FontAwesomeIcons.eye,
                                                color: Color(0xFF1E88E5),
                                              ),
                                              onPressed: () async {
                                                if (await fileObj.exists()) {
                                                  if (mounted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FilePreviewScreen(
                                                                file: fileObj),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "Le fichier n’existe plus"),
                                                        backgroundColor:
                                                            Color(0xFFF44336),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              tooltip:
                                                  'Prévisualiser le fichier',
                                            ),
                                            IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.trash,
                                                color: Color(0xFFF44336),
                                              ),
                                              onPressed: () async {
                                                await _deleteFile(file.id!);
                                              },
                                              tooltip: 'Supprimer le fichier',
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
              icon: const FaIcon(FontAwesomeIcons.clockRotateLeft),
              label: const Text('Voir l’historique',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
