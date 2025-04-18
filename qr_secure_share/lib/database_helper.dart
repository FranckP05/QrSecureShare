import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// J efais un modèle pour un lien partagé
class SharedLink {
  final int? id;
  final String url;
  final String createdAt;

  SharedLink({this.id, required this.url, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'created_at': createdAt,
    };
  }

  factory SharedLink.fromMap(Map<String, dynamic> map) {
    return SharedLink(
      id: map['id'],
      url: map['url'],
      createdAt: map['created_at'],
    );
  }
}

// De même pour un fichier partagé
class SharedFile {
  final int? id;
  final String path;
  final String name;
  final String createdAt;

  SharedFile(
      {this.id,
      required this.path,
      required this.name,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory SharedFile.fromMap(Map<String, dynamic> map) {
    return SharedFile(
      id: map['id'],
      path: map['path'],
      name: map['name'],
      createdAt: map['created_at'],
    );
  }
}

// ....mot de passe partagé
class SharedPassword {
  final int? id;
  final String password;
  final String createdAt;

  SharedPassword({this.id, required this.password, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory SharedPassword.fromMap(Map<String, dynamic> map) {
    return SharedPassword(
      id: map['id'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }
}

// ... pour un identifiant Wi-Fi partagé
class SharedWifi {
  final int? id;
  final String ssid;
  final String password;
  final String createdAt;

  SharedWifi(
      {this.id,
      required this.ssid,
      required this.password,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ssid': ssid,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory SharedWifi.fromMap(Map<String, dynamic> map) {
    return SharedWifi(
      id: map['id'],
      ssid: map['ssid'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }
}

// Je creer une Classe pour gérer la base de données SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // J'ouvre / crée la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('qr_secure_share.db');
    return _database!;
  }

  // J'innitialise la base de données
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // de ême, je crée les tables nécessaires
  Future _createDB(Database db, int version) async {
    // Table pour les liens partagés
    await db.execute('''
    CREATE TABLE shared_links (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      url TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    // Table pour les fichiers partagés
    await db.execute('''
    CREATE TABLE shared_files (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      path TEXT NOT NULL,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    // Table pour les mots de passe partagés
    await db.execute('''
    CREATE TABLE shared_passwords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      password TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    // Table pour les identifiants Wi-Fi partagés
    await db.execute('''
    CREATE TABLE shared_wifi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ssid TEXT NOT NULL,
      password TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');
  }

  // --- Je met une Opérations CRUD pour les liens partagés ---

  // Ajoute un lien partagé
  Future<void> insertLink(SharedLink link) async {
    final db = await database;
    await db.insert('shared_links', link.toMap());
  }

  // Récupère tous les liens partagés
  Future<List<SharedLink>> getLinks() async {
    final db = await database;
    final maps = await db.query('shared_links', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SharedLink.fromMap(maps[i]));
  }

  // Supprime un lien partagé par ID
  Future<void> deleteLink(int id) async {
    final db = await database;
    await db.delete('shared_links', where: 'id = ?', whereArgs: [id]);
  }

  // Supprime tous les liens partagés
  Future<void> clearLinks() async {
    final db = await database;
    await db.delete('shared_links');
  }

  // --- Opérations CRUD pour les fichiers partagés ---

  // Ajoute un fichier partagé
  Future<void> insertFile(SharedFile file) async {
    final db = await database;
    await db.insert('shared_files', file.toMap());
  }

  // Récupère tous les fichiers partagés
  Future<List<SharedFile>> getFiles() async {
    final db = await database;
    final maps = await db.query('shared_files', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SharedFile.fromMap(maps[i]));
  }

  // Supprime un fichier partagé par ID
  Future<void> deleteFile(int id) async {
    final db = await database;
    await db.delete('shared_files', where: 'id = ?', whereArgs: [id]);
  }

  // Supprime tous les fichiers partagés
  Future<void> clearFiles() async {
    final db = await database;
    await db.delete('shared_files');
  }

  // --- Opérations CRUD pour les mots de passe partagés ---

  // Ajoute un mot de passe partagé
  Future<void> insertPassword(SharedPassword password) async {
    final db = await database;
    await db.insert('shared_passwords', password.toMap());
  }

  // Récupère tous les mots de passe partagés
  Future<List<SharedPassword>> getPasswords() async {
    final db = await database;
    final maps = await db.query('shared_passwords', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SharedPassword.fromMap(maps[i]));
  }

  // Supprime un mot de passe partagé par ID
  Future<void> deletePassword(int id) async {
    final db = await database;
    await db.delete('shared_passwords', where: 'id = ?', whereArgs: [id]);
  }

  // Supprime tous les mots de passe partagés
  Future<void> clearPasswords() async {
    final db = await database;
    await db.delete('shared_passwords');
  }

  // --- Opérations CRUD pour les identifiants Wi-Fi partagés ---

  // Ajoute un identifiant Wi-Fi partagé
  Future<void> insertWifi(SharedWifi wifi) async {
    final db = await database;
    await db.insert('shared_wifi', wifi.toMap());
  }

  // Récupère tous les identifiants Wi-Fi partagés
  Future<List<SharedWifi>> getWifi() async {
    final db = await database;
    final maps = await db.query('shared_wifi', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SharedWifi.fromMap(maps[i]));
  }

  // Supprime un identifiant Wi-Fi partagé par ID
  Future<void> deleteWifi(int id) async {
    final db = await database;
    await db.delete('shared_wifi', where: 'id = ?', whereArgs: [id]);
  }

  // Supprime tous les identifiants Wi-Fi partagés
  Future<void> clearWifi() async {
    final db = await database;
    await db.delete('shared_wifi');
  }

  // Je ferme la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
