import 'package:sqflite/sqflite.dart';
import '../models/invoice.dart';
import '../database/database_helper.dart';

class InvoiceDatabase {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'invoices';

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await dbHelper.database;
    return await db!.insert(tableName, invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) {
      return Invoice.fromMap(maps[i]);
    });
  }

  Future<int> getSellCountsByYear(int year) async {
    final db = await dbHelper.database;
    if (db == null) {
      return 0; // Return 0 if db is null
    }

    final result = await db.rawQuery('''
    SELECT COUNT(*)
    FROM invoices
    WHERE strftime('%Y', date) = ? AND action = 'Sell'
  ''', [year.toString()]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getBuyCountsByYear(int year) async {
    final db = await dbHelper.database;
    if (db == null) {
      return 0; // Return 0 if db is null
    }

    final result = await db.rawQuery('''
    SELECT COUNT(*)
    FROM invoices
    WHERE strftime('%Y', date) = ? AND action = 'Buy'
  ''', [year.toString()]);

    return Sqflite.firstIntValue(result) ?? 0;
  }
  //TODO: insted of count i should use last id of invoice so when invoice was deleted there is no chance for double refID

  Future<int> deleteInvoice(int id) async {
    final db = await dbHelper.database;
    return await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await dbHelper.database;
    return await db!.update(
      tableName,
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }
}
