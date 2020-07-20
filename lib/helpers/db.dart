import 'dart:io';
import 'package:g2r_market/helpers/user_base.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'auth_base.dart';

class DBProvider {

  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
    return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "MarketDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Auth ("
          "id INTEGER PRIMARY KEY,"
          "token TEXT"
          ")");

      await db.execute("CREATE TABLE Account ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "last_name TEXT,"
          "patronymic TEXT,"
          "birthday TEXT,"
          "phone TEXT,"
          "avatar TEXT"
          ")");
    });
  }

  newAuth(AuthBase newClient) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Auth");
    int id = table.first["id"] ?? 1;
    //insert to the table using the new id 
    var raw = await db.rawInsert(
        "INSERT Into Auth (id,token)"
        " VALUES (?,?)",
        [id, newClient.token]);
    return raw;
  }

  newAccountInfo(UserBase newClient) async {
    final db = await database;
    //get the biggest id in the table
    int id = 1;
    //insert to the table using the new id 
    var raw = await db.rawInsert(
        "INSERT Into Account (id, name, last_name, patronymic, birthday, phone, avatar)"
        " VALUES (?, ?, ?, ?, ?, ?, ?)",
        [id, newClient.name, newClient.lastName, newClient.patronymic, newClient.birthday, newClient.phone, newClient.avatar]);
    return raw;
  }

  updateAccountInfo(UserBase newClient) async {
    final db = await database;
    var res = await db.update("Account", newClient.toMap(),
        where: "id = ?", whereArgs: [1]
    );
    return res;
  }

  deleteAccountInfo() async {
    final db = await database;
    var res = await db.delete("Account",
      where: 'id = ?', whereArgs: [1]
    );
    return res;
  }

  deleteAuth() async {
    final db = await database;
    var res = await db.delete("Auth",
      where: 'id = ?', whereArgs: [1]
    );
    return res;
  }

  getAuth(int id) async {
    final db = await database;
    var res =await  db.query("Auth", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? res.first : Null ;
  }

  getAccountInfo(int id) async {
    final db = await database;
    var res =await  db.query("Account", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? res.first : Null ;
  }
}