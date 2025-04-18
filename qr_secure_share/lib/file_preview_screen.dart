import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;

// Je met mon écran pour prévisualiser un fichier
class FilePreviewScreen extends StatelessWidget {
  final File file;

  const FilePreviewScreen({super.key, required this.file});

  // Je m'asssur  si le fichier est une image
  bool _isImage(String path) {
    return path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.gif');
  }

  // Je détermine si le fichier est un fichier texte
  bool _isText(String path) {
    return path.toLowerCase().endsWith('.txt');
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(file.path);
    final isImage = _isImage(file.path);
    final isText = _isText(file.path);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévisualisation du fichier'),
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
            Text(
              'Nom du fichier : $fileName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: file.length(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Taille : ${(snapshot.data! / 1024).toStringAsFixed(2)} KB',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Erreur : Impossible de lire la taille du fichier',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.red),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<bool>(
                future: file.exists(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!) {
                    if (isImage) {
                      return Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.file,
                                size: 50,
                                color: Color(0xFF1E88E5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Erreur lors du chargement de l’image',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (isText) {
                      return FutureBuilder<String>(
                        future: file.readAsString(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Text(
                                snapshot.data!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Erreur lors de la lecture du fichier',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.file,
                              size: 50,
                              color: Color(0xFF1E88E5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Prévisualisation non disponible pour ce type de fichier',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  } else if (snapshot.hasError ||
                      (snapshot.hasData && !snapshot.data!)) {
                    return Center(
                      child: Text(
                        'Le fichier n’existe plus ou est inaccessible',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const FaIcon(FontAwesomeIcons.arrowLeft),
              label: const Text('Retour', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
