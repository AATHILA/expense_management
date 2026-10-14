import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/credit.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';

/// Thrown for any SQLite problem so the UI can show a friendly message.
class DbFailure implements Exception {
  final String message;
  const DbFailure(this.message);
  @override
  String toString() => message;
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'expenzia.db';
  static const _expenses = 'expenses';
  static const _credits = 'credits';
  static const _profile = 'profile';

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createExpenses(db);
        await _createCredits(db);
        await _createProfile(db);
      },
      // Upgrades only add new tables, existing data is kept
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) await _createCredits(db);
        if (oldV < 3) await _createProfile(db);
      },
    );
  }

  Future<void> _createExpenses(Database db) => db.execute('''
        CREATE TABLE $_expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT
        )
      ''');

  Future<void> _createCredits(Database db) => db.execute('''
        CREATE TABLE $_credits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          credit_type TEXT NOT NULL,
          to_name TEXT NOT NULL,
          date TEXT NOT NULL,
          plan_type TEXT NOT NULL,
          amount REAL NOT NULL
        )
      ''');

  Future<void> _createProfile(Database db) => db.execute('''
        CREATE TABLE $_profile (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          photo_path TEXT
        )
      ''');

  Future<T> _guard<T>(Future<T> Function() action, String what) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw DbFailure('Could not $what. ($e)');
    } catch (e) {
      throw DbFailure('Unexpected error while trying to $what.');
    }
  }

  // ---- Expenses CRUD ----

  Future<int> insert(Expense e) => _guard(() async {
        final db = await _database;
        return db.insert(_expenses, e.toMap()..remove('id'));
      }, 'save the expense');

  Future<List<Expense>> getAll() => _guard(() async {
        final db = await _database;
        final rows = await db.query(_expenses, orderBy: 'date DESC, id DESC');
        return rows.map(Expense.fromMap).toList();
      }, 'load expenses');

  Future<int> update(Expense e) => _guard(() async {
        final db = await _database;
        return db.update(_expenses, e.toMap()..remove('id'),
            where: 'id = ?', whereArgs: [e.id]);
      }, 'update the expense');

  Future<int> delete(int id) => _guard(() async {
        final db = await _database;
        return db.delete(_expenses, where: 'id = ?', whereArgs: [id]);
      }, 'delete the expense');

  // ---- Credits CRUD ----

  Future<int> insertCredit(Credit c) => _guard(() async {
        final db = await _database;
        return db.insert(_credits, c.toMap()..remove('id'));
      }, 'save the credit');

  /// Soonest due date first.
  Future<List<Credit>> getCredits() => _guard(() async {
        final db = await _database;
        final rows = await db.query(_credits, orderBy: 'date ASC, id DESC');
        return rows.map(Credit.fromMap).toList();
      }, 'load saved credits');

  Future<int> deleteCredit(int id) => _guard(() async {
        final db = await _database;
        return db.delete(_credits, where: 'id = ?', whereArgs: [id]);
      }, 'delete the credit');

  // ---- Profile ----

  Future<UserProfile> getProfile() => _guard(() async {
        final db = await _database;
        final rows = await db.query(_profile, where: 'id = 1');
        return rows.isEmpty ? UserProfile.defaults : UserProfile.fromMap(rows.first);
      }, 'load the profile');

  Future<void> saveProfile(UserProfile p) => _guard(() async {
        final db = await _database;
        await db.insert(_profile, p.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }, 'save the profile');

  // ---- Clear storage ----

  Future<void> deleteAllExpenses() => _guard(() async {
        final db = await _database;
        await db.delete(_expenses);
      }, 'clear expenses');

  Future<void> deleteAllCredits() => _guard(() async {
        final db = await _database;
        await db.delete(_credits);
      }, 'clear saved credits');
}
