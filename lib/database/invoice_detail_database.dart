import 'package:sqflite/sqflite.dart';
import '../models/invoice_detail.dart';
import 'database_helper.dart';

class InvoiceDetailDatabase {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'invoice_details';

  Future<int> insertInvoiceDetail(InvoiceDetail InvoiceDetail) async {
    final db = await dbHelper.database;
    return await db!.insert(tableName, InvoiceDetail.toMap());
  }

  Future<List<InvoiceDetail>> getInvoiceDetailsByInvoice(int invoiceId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      tableName,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
    return List.generate(maps.length, (i) {
      return InvoiceDetail.fromMap(maps[i]);
    });
  }

  Future<int> deleteInvoiceDetail(int id) async {
    final db = await dbHelper.database;
    return await db!.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteInvoiceDetailsByInvoice(int invoiceId) async {
    final db = await dbHelper.database;
    return await db!.delete(
      tableName,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }
}