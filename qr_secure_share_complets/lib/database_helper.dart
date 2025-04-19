import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SharedLink {
  final int? id;
  final String url;
  final String createdAt;

  SharedLink({this.id, required this.url, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'createdAt': createdAt,
    };
  }

  static SharedLink fromMap(Map<String, dynamic> map) {
    return SharedLink(
      id: map['id'],
      url: map['url'],
      createdAt: map['createdAt'],
    );
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
      'createdAt': createdAt,
    };
  }

  static SharedPassword fromMap(Map<String, dynamic> map) {
    return SharedPassword(
      id: map['id'],
      password: map['password'],
      createdAt: map['createdAt'],
    );
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
      'createdAt': createdAt,
    };
  }

  static SharedWifi fromMap(Map<String, dynamic> map) {
    return SharedWifi(
      id: map['id'],
      ssid: map['ssid'],
      password: map['password'],
      createdAt: map['createdAt'],
    );
  }
}

class SharedFile {
  final int? id;
  final String path;
  final String name;
  final String createdAt;

  SharedFile({
    this.id,
    required this.path,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'createdAt': createdAt,
    };
  }

  static SharedFile fromMap(Map<String, dynamic> map) {
    return SharedFile(
      id: map['id'],
      path: map['path'],
      name: map['name'],
      createdAt: map['createdAt'],
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
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shared_links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE shared_passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            password TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE shared_wifi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ssid TEXT NOT NULL,
            password TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE shared_files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Méthodes pour les liens
  Future<void> insertLink(SharedLink link) async {
    final db = await instance.database;
    await db.insert('shared_links', link.toMap());
  }

  Future<List<SharedLink>> getLinks() async {
    final db = await instance.database;
    final maps = await db.query('shared_links', orderBy: 'createdAt DESC');
    return maps.map((map) => SharedLink.fromMap(map)).toList();
  }

  Future<void> deleteLink(int id) async {
    final db = await instance.database;
    await db.delete('shared_links', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearLinks() async {
    final db = await instance.database;
    await db.delete('shared_links');
  }

  // Méthodes pour les mots de passe
  Future<void> insertPassword(SharedPassword password) async {
    final db = await instance.database;
    await db.insert('shared_passwords', password.toMap());
  }

  Future<List<SharedPassword>> getPasswords() async {
    final db = await instance.database;
    final maps = await db.query('shared_passwords', orderBy: 'createdAt DESC');
    return maps.map((map) => SharedPassword.fromMap(map)).toList();
  }

  Future<void> deletePassword(int id) async {
    final db = await instance.database;
    await db.delete('shared_passwords', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPasswords() async {
    final db = await instance.database;
    await db.delete('shared_passwords');
  }

  // Méthodes pour les Wi-Fi
  Future<void> insertWifi(SharedWifi wifi) async {
    final db = await instance.database;
    await db.insert('shared_wifi', wifi.toMap());
  }

  Future<List<SharedWifi>> getWifi() async {
    final db = await instance.database;
    final maps = await db.query('shared_wifi', orderBy: 'createdAt DESC');
    return maps.map((map) => SharedWifi.fromMap(map)).toList();
  }

  Future<void> deleteWifi(int id) async {
    final db = await instance.database;
    await db.delete('shared_wifi', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearWifi() async {
    final db = await instance.database;
    await db.delete('shared_wifi');
  }

  // Méthodes pour les fichiers
  Future<void> insertFile(SharedFile file) async {
    final db = await instance.database;
    await db.insert('shared_files', file.toMap());
  }

  Future<List<SharedFile>> getFiles() async {
    final db = await instance.database;
    final maps = await db.query('shared_files', orderBy: 'createdAt DESC');
    return maps.map((map) => SharedFile.fromMap(map)).toList();
  }

  Future<void> deleteFile(int id) async {
    final db = await instance.database;
    await db.delete('shared_files', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearFiles() async {
    final db = await instance.database;
    await db.delete('shared_files');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
