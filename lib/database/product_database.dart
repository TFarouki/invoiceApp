import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import 'database_helper.dart';

class ProductDatabase {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'products';

  Future<int> insertProduct(Product product) async {
    final db = await dbHelper.database;
    return await db!.insert(tableName, product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await dbHelper.database;
    return await db!.update(
      tableName,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await dbHelper.database;
    return await db!.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}