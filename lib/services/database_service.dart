import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web平台初始化
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'personal_accounting.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDb,
        ),
      );
    } else {
      // 移动端和桌面端初始化
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'personal_accounting.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
  }

  Future<List<model.Transaction>> getTransactionsByType(model.TransactionType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.toString().split('.').last],
    );
    return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
  }

  Future<List<model.Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toString().split(' ')[0],
        endDate.toString().split(' ')[0],
      ],
    );
    return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
  }

  Future<Map<model.Category, double>> getCategorySum(model.TransactionType type) async {
    final transactions = await getTransactionsByType(type);
    final Map<model.Category, double> result = {};
    
    for (var transaction in transactions) {
      if (result.containsKey(transaction.category)) {
        result[transaction.category] = result[transaction.category]! + transaction.amount;
      } else {
        result[transaction.category] = transaction.amount;
      }
    }
    
    return result;
  }
}