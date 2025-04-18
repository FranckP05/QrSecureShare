import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

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
    print('Database path: $path');
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE User(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name_user TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          force_password_change INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE data(
          id_data INTEGER PRIMARY KEY AUTOINCREMENT,
          id_type INTEGER NOT NULL,
          id_user INTEGER NOT NULL,
          encrypted_content TEXT NOT NULL,
          date TEXT NOT NULL, 
          FOREIGN KEY (id_user) REFERENCES User(id)
        )
      ''');
      await db.execute('''
        CREATE TABLE types(
          id_type INTEGER PRIMARY KEY AUTOINCREMENT,
          type_name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE keys(
          id_key INTEGER PRIMARY KEY AUTOINCREMENT,
          id_data INTEGER NOT NULL,
          aes_key TEXT NOT NULL,
          iv TEXT NOT NULL,
          FOREIGN KEY (id_data) REFERENCES data(id_data)
        )
      ''');
      print('Database tables created successfully');
    } catch (e) {
      print('Error creating tables: $e');
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE User ADD COLUMN force_password_change INTEGER NOT NULL DEFAULT 0');
        print('Added force_password_change column');
      } catch (e) {
        print('Error upgrading database: $e');
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE keys(
            id_key INTEGER PRIMARY KEY AUTOINCREMENT,
            id_data INTEGER NOT NULL,
            aes_key TEXT NOT NULL,
            iv TEXT NOT NULL,
            FOREIGN KEY (id_data) REFERENCES data(id_data)
          )
        ''');
        print('Added keys table');
      } catch (e) {
        print('Error upgrading database: $e');
      }
    }
  }

  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM User');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> createUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty || username.length > 50) {
      print('Invalid input: username=$username, password length=${password.length}');
      return false;
    }
    final db = await database;
    if (await getUserCount() > 0) {
      print('User already exists');
      return false;
    }
    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      await db.insert(
        'User',
        {'name_user': username.trim(), 'password': hashedPassword, 'force_password_change': 0},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      print('User created: $username');
      return true;
    } catch (e) {
      print('Create user error: $e');
      return false;
    }
  }

  Future<bool> authenticateUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      print('Invalid input: username=$username');
      return false;
    }
    final db = await database;
    try {
      final result = await db.query(
        'User',
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      if (result.isEmpty) {
        print('No user found: $username');
        return false;
      }
      final user = result.first;
      final storedPassword = user['password'] as String?;
      if (storedPassword == null) {
        print('No password found for user: $username');
        return false;
      }
      return BCrypt.checkpw(password, storedPassword);
    } catch (e) {
      print('Authenticate user error: $e');
      return false;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    final db = await database;
    try {
      final result = await db.query(
        'User',
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Check username error: $e');
      return false;
    }
  }

  Future<void> setForcePasswordChange(String username, bool value) async {
    final db = await database;
    try {
      await db.update(
        'User',
        {'force_password_change': value ? 1 : 0},
        where: 'name with name_user = ?',
        whereArgs: [username.trim()],
      );
      print('Set force_password_change=$value for $username');
    } catch (e) {
      print('Error setting force_password_change: $e');
    }
  }

  Future<bool> getUserForcePasswordChange(String username) async {
    final db = await database;
    try {
      final result = await db.query(
        'User',
        columns: ['force_password_change'],
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      if (result.isEmpty) {
        print('No user found: $username');
        return false;
      }
      final user = result.first;
      final forcePasswordChange = user['force_password_change'] as int?;
      return forcePasswordChange == 1;
    } catch (e) {
      print('Error getting force_password_change: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String username, String newPassword) async {
    if (newPassword.isEmpty || newPassword.length > 50) {
      print('Invalid password: length=${newPassword.length}');
      return false;
    }
    final db = await database;
    try {
      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await db.update(
        'User',
        {'password': hashedPassword, 'force_password_change': 0},
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      print('Password updated for $username');
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  Future<int> insertData({
    required String username,
    required String content,
    required String typeName,
    required String date,
  }) async {
    final db = await database;
    try {
      // Get user ID
      final userResult = await db.query(
        'User',
        columns: ['id'],
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      if (userResult.isEmpty) {
        print('No user found: $username');
        return 0;
      }
      final userId = userResult.first['id'] as int?;
      if (userId == null) {
        print('No user ID found for: $username');
        return 0;
      }

      // Get or insert type
      var typeResult = await db.query(
        'types',
        where: 'type_name = ?',
        whereArgs: [typeName],
      );
      int typeId;
      if (typeResult.isEmpty) {
        typeId = await db.insert('types', {'type_name': typeName});
      } else {
        typeId = typeResult.first['id_type'] as int;
      }

      // Encrypt content
      final aesKey = encrypt.Key.fromSecureRandom(32); // 256-bit AES
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
      final encryptedContent = encrypter.encrypt(content, iv: iv);

      // Insert data
      final dataId = await db.insert('data', {
        'id_type': typeId,
        'id_user': userId,
        'encrypted_content': encryptedContent.base64,
        'date': date,
      });

      // Store key and IV
      await db.insert('keys', {
        'id_data': dataId,
        'aes_key': aesKey.base64,
        'iv': iv.base64,
      });

      print('Inserted data: $dataId for $username');
      return dataId;
    } catch (e) {
      print('Error inserting data: $e');
      return 0;
    }
  }

  Future<String?> decryptContent(int dataId) async {
    final db = await database;
    try {
      final keyResult = await db.query(
        'keys',
        where: 'id_data = ?',
        whereArgs: [dataId],
      );
      if (keyResult.isEmpty) {
        print('No key found for data ID: $dataId');
        return null;
      }
      final keyData = keyResult.first;
      final aesKeyBase64 = keyData['aes_key'] as String?;
      final ivBase64 = keyData['iv'] as String?;
      if (aesKeyBase64 == null || ivBase64 == null) {
        print('Invalid key or IV for data ID: $dataId');
        return null;
      }

      final aesKey = encrypt.Key.fromBase64(aesKeyBase64);
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));

      final dataResult = await db.query(
        'data',
        where: 'id_data = ?',
        whereArgs: [dataId],
      );
      if (dataResult.isEmpty) {
        print('No data found for ID: $dataId');
        return null;
      }
      final encryptedContent = dataResult.first['encrypted_content'] as String?;
      if (encryptedContent == null) {
        print('No encrypted content for data ID: $dataId');
        return null;
      }

      final decrypted = encrypter.decrypt64(encryptedContent, iv: iv);
      return decrypted;
    } catch (e) {
      print('Error decrypting content: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDataHistory(String username) async {
    final db = await database;
    try {
      // Get user ID
      final userResult = await db.query(
        'User',
        columns: ['id'],
        where: 'name_user = ?',
        whereArgs: [username.trim()],
      );
      if (userResult.isEmpty) {
        print('No user found: $username');
        return [];
      }
      final userId = userResult.first['id'] as int?;
      if (userId == null) {
        print('No user ID found for: $username');
        return [];
      }

      // Query data with type names and IDs
      final result = await db.rawQuery('''
        SELECT 
          d.id_data,
          t.type_name,
          d.encrypted_content,
          d.date
        FROM data d
        LEFT JOIN types t ON d.id_type = t.id_type
        WHERE d.id_user = ?
        ORDER BY d.date DESC
      ''', [userId]);

      // Decrypt content for each entry
      final decryptedResult = <Map<String, dynamic>>[];
      for (var item in result) {
        final dataId = item['id_data'] as int?;
        String? content;
        if (dataId != null) {
          content = await decryptContent(dataId);
        }
        decryptedResult.add({
          'id_data': dataId,
          'type_name': item['type_name'],
          'content': content ?? 'Decryption failed',
          'date': item['date'],
        });
      }

      return decryptedResult;
    } catch (e) {
      print('Error getting data history: $e');
      return [];
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}