import 'dart:developer';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    Database myDb = await databaseFactoryFfi.openDatabase(
      await getDbPath(),
      options: OpenDatabaseOptions(
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: 2,
      ),
    );
    return myDb;
  }

  static Future<String> getDbPath() async {
    var databasesPath = await getDatabasesPath();
    sqfliteFfiInit();
    return join(databasesPath, 'notifications.db');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {
    log("onUpgrade =====================================");
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE "notifications" (
    "id" INTEGER NOT NULL PRIMARY KEY, 
    "title" TEXT NOT NULL,
    "text" TEXT,
    "url" TEXT,
    "image_full_link" TEXT ,
    "warehouses_ids",
    "repeated" INTEGER NOT NULL,
    "showed" INTEGER NOT NULL 
  )
 ''');
    await db.execute('''
  CREATE TABLE "notifications2" (
    "id" INTEGER NOT NULL PRIMARY KEY, 
    "title" TEXT NOT NULL,
    "text" TEXT,
    "url" TEXT,
    "image_full_link" TEXT
  )
 ''');
    log(" onCreate =====================================");
  }
  readData(String sql) async {
    Database? myDb = await db;
    List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }
  Future insertData(String sql) async {
    try{
      Database? myDb = await db;
      int response = await myDb!.rawInsert(sql);
      return response;
    }catch(e){
      print(e);
    }

  }

  updateData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    try{
      Database? myDb = await db;
      int response = await myDb!.rawDelete(sql);
      return response;
    }catch(e){
      print(e);
    }

  }
}
