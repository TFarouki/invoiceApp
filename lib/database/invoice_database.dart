import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/invoice.dart';

class InvoiceDatabase {
  static final InvoiceDatabase instance = InvoiceDatabase._init();
  static Database? _database;

  InvoiceDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('invoice.db');
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
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        refInvoice INTEGER,
        date INTEGER,
        action TEXT,
        contactId INTEGER,
        total REAL,
        paymentMethod TEXT
      )
    ''');
  }

  Future<int> createInvoice(Invoice invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await instance.database;
    final result = await db.query('invoices');
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<int> getNextSellRefInvoice() async {
    return await _getNextRefInvoiceForAction('Sell');
  }

  Future<int> getNextBuyRefInvoice() async {
    return await _getNextRefInvoiceForAction('Buy');
  }

  Future<int> _getNextRefInvoiceForAction(String action) async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year).millisecondsSinceEpoch;
    final end = DateTime(now.year + 1).millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT MAX(refInvoice) as maxRef
      FROM invoices
      WHERE date >= ? AND date < ? AND action = ?
      ''',
      [start, end, action],
    );

    final maxRef = result.first['maxRef'] as int?;
    return (maxRef ?? 0) + 1;
  }
}