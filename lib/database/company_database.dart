import 'package:sqflite/sqflite.dart';
import '../models/company.dart';
import 'database_helper.dart';

class CompanyDatabase {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'company';

  // Insert a new company into the database
  Future<int> insertCompany(Company company) async {
    final db = await dbHelper.database;
    return await db!.insert(tableName, company.toMap());
  }

  // Get all companies from the database
  Future<List<Company>> getAllCompanies() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) {
      return Company.fromMap(maps[i]);
    });
  }

  // Update an existing company in the database
  Future<int> updateCompany(Company company) async {
    final db = await dbHelper.database;
    return await db!.update(
      tableName,
      company.toMap(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  // Delete a company from the database by its id
  Future<int> deleteCompany(int id) async {
    final db = await dbHelper.database;
    return await db!.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
