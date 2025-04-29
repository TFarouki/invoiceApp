import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import 'database_helper.dart';

class ContactDatabase {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'contacts';

  Future<int> insertContact(Contact contact) async {
    final db = await dbHelper.database;
    return await db!.insert(tableName, contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<Contact?> getContactById(int id) async {
    final db = await dbHelper.database;
    final maps = await db!.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateContact(Contact contact) async {
    final db = await dbHelper.database;
    return await db!.update(
      tableName,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await dbHelper.database;
    return await db!.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}