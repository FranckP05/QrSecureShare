import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart'; // Add bcrypt package for password hashing

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE User(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name_user TEXT NOT NULL UNIQUE, -- Added UNIQUE constraint
          password TEXT NOT NULL
        )
      ''');
    await db.execute('''
      CREATE TABLE data(
        id_data INTEGER PRIMARY KEY AUTOINCREMENT,
        id_type INTEGER NOT NULL,
        id_user INTEGER NOT NULL,
        encrypted_content TEXT NOT NULL,
        date TEXT NOT NULL, 
        FOREIGN KEY (id_user) REFERENCES User(id) -- Fixed syntax
      )
    ''');
    await db.execute('''
      CREATE TABLE types(
        id_type INTEGER PRIMARY KEY AUTOINCREMENT, -- Added PRIMARY KEY
        type_name TEXT NOT NULL
      )
    ''');
  }

  // User Table Functions

  Future<int> getUserCount() async {
    final db = await database;
    //rawQuery with parameterized count to avoid SQL injection
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM User');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Creates a new user if no user exists, with hashed password
  Future<bool> createUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty || username.length > 50) {
      return false; 
    }
    final db = await database;
    // Check if a user already exists
    if (await getUserCount() > 0) {
      return false; // Only one user allowed
    }
    try {
      // Hash password with bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      // parameterized query to prevent SQL injection
      await db.insert(
        'User',
        {
          'name_user': username.trim(),
          'password': hashedPassword,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  /// Authentication
  Future<bool> authenticateUser(String username, String password) async {
    // Input validation
    if (username.isEmpty || password.isEmpty) {
      return false;
    }
    final db = await database;
    try {
      // parameterized query to prevent SQL injection
      final result = await db.query(
        'User',
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      if (result.isEmpty) {
        return false; 
      }
      // Verify password
      final storedPassword = result.first['password'] as String;
      return BCrypt.checkpw(password, storedPassword);
    } catch (e) {
      // Log error securely
      print('Error authenticating user: $e');
      return false;
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}