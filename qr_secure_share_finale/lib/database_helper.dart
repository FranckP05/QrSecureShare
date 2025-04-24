import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class SharedLink {
  final int? id;
  final String link;
  final String createdAt;

  SharedLink({this.id, required this.link, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'link': link,
      'created_at': createdAt,
    };
  }
}

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
}

class SharedWifi {
  final int? id;
  final String ssid;
  final String password;
  final String createdAt;

  SharedWifi({
    this.id,
    required this.ssid,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ssid': ssid,
      'password': password,
      'created_at': createdAt,
    };
  }
}

class SharedFile {
  final int? id;
  final String name;
  final String path;
  final String createdAt;

  SharedFile({
    this.id,
    required this.name,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'created_at': createdAt,
    };
  }
}

class PublicKey {
  final int? id;
  final String name;
  final String keyBase64;
  final String createdAt;

  PublicKey({
    this.id,
    required this.name,
    required this.keyBase64,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'key_base64': keyBase64,
      'created_at': createdAt,
    };
  }

  factory PublicKey.fromMap(Map<String, dynamic> map) {
    return PublicKey(
      id: map['id'],
      name: map['name'],
      keyBase64: map['key_base64'],
      createdAt: map['created_at'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('qr_secure_share.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        link TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wifi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ssid TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE public_keys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        key_base64 TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Méthodes pour les liens
  Future<void> insertLink(SharedLink link) async {
    final db = await instance.database;
    await db.insert('links', link.toMap());
  }

  Future<List<SharedLink>> getLinks() async {
    final db = await instance.database;
    final result = await db.query('links', orderBy: 'created_at DESC');
    return result
        .map((map) => SharedLink(
              id: map['id'] as int,
              link: map['link'] as String,
              createdAt: map['created_at'] as String,
            ))
        .toList();
  }

  Future<void> deleteLink(int id) async {
    final db = await instance.database;
    await db.delete('links', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearLinks() async {
    final db = await instance.database;
    await db.delete('links');
  }

  // Méthodes pour les mots de passe
  Future<void> insertPassword(SharedPassword password) async {
    final db = await instance.database;
    await db.insert('passwords', password.toMap());
  }

  Future<List<SharedPassword>> getPasswords() async {
    final db = await instance.database;
    final result = await db.query('passwords', orderBy: 'created_at DESC');
    return result
        .map((map) => SharedPassword(
              id: map['id'] as int,
              password: map['password'] as String,
              createdAt: map['created_at'] as String,
            ))
        .toList();
  }

  Future<void> deletePassword(int id) async {
    final db = await instance.database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPasswords() async {
    final db = await instance.database;
    await db.delete('passwords');
  }

  // Méthodes pour le Wi-Fi
  Future<void> insertWifi(SharedWifi wifi) async {
    final db = await instance.database;
    await db.insert('wifi', wifi.toMap());
  }

  Future<List<SharedWifi>> getWifi() async {
    final db = await instance.database;
    final result = await db.query('wifi', orderBy: 'created_at DESC');
    return result
        .map((map) => SharedWifi(
              id: map['id'] as int,
              ssid: map['ssid'] as String,
              password: map['password'] as String,
              createdAt: map['created_at'] as String,
            ))
        .toList();
  }

  Future<void> deleteWifi(int id) async {
    final db = await instance.database;
    await db.delete('wifi', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearWifi() async {
    final db = await instance.database;
    await db.delete('wifi');
  }

  // Méthodes pour les fichiers
  Future<void> insertFile(SharedFile file) async {
    final db = await instance.database;
    await db.insert('files', file.toMap());
  }

  Future<List<SharedFile>> getFiles() async {
    final db = await instance.database;
    final result = await db.query('files', orderBy: 'created_at DESC');
    return result
        .map((map) => SharedFile(
              id: map['id'] as int,
              name: map['name'] as String,
              path: map['path'] as String,
              createdAt: map['created_at'] as String,
            ))
        .toList();
  }

  Future<void> deleteFile(int id) async {
    final db = await instance.database;
    final file =
        (await db.query('files', where: 'id = ?', whereArgs: [id])).first;
    final path = file['path'] as String;
    final fileToDelete = File(path);
    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
    }
    await db.delete('files', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearFiles() async {
    final db = await instance.database;
    final files = await db.query('files');
    for (var file in files) {
      final path = file['path'] as String;
      final fileToDelete = File(path);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }
    }
    await db.delete('files');
  }

  // Méthodes pour les clés publiques
  Future<void> insertPublicKey(PublicKey publicKey) async {
    final db = await instance.database;
    await db.insert('public_keys', publicKey.toMap());
  }

  Future<List<PublicKey>> getPublicKeys() async {
    final db = await instance.database;
    final result = await db.query('public_keys', orderBy: 'created_at DESC');
    return result.map((map) => PublicKey.fromMap(map)).toList();
  }

  Future<void> deletePublicKey(int id) async {
    final db = await instance.database;
    await db.delete('public_keys', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPublicKeys() async {
    final db = await instance.database;
    await db.delete('public_keys');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
