import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Bảng user
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            username TEXT,
            password TEXT,
            phone TEXT
          )
        ''');

        // Bảng ghi chú
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            content TEXT,
            created_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // ================== USER ==================
  Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<bool> emailExists(String email) async {
    final dbClient = await db;
    final result =
        await dbClient.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  // ================== NOTES ==================
  Future<List<Map<String, dynamic>>> getNotesByUser(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> insertNote(int userId, String content) async {
    final dbClient = await db;
    return await dbClient.insert('notes', {
      'user_id': userId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> deleteNote(int id) async {
    final dbClient = await db;
    return await dbClient.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
