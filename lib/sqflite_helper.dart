import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';

class SQLHelper {
  // create sqflite  table
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
  CREATE TABLE items(
  id INTEGER  PRIMARY key AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
""");
  }

//create main database
  static Future<sql.Database> db() async {
    return sql.openDatabase('todo.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

//create or insert items
  static Future<int> createItem(String title, String description) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

// get all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id');
  }

//get single item
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id=?", whereArgs: [id], limit: 1);
  }

//update item
  static Future<int> updateItem(
      int id, String title, String description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id=?", whereArgs: [id]);
    return result;
  }

//delete item
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      db.delete('items', where: "id=?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deletuing items$err");
    }
  }
}
