import 'dart:async';
import 'package:couchdb_sqlite_sync/database/database.dart';
import 'package:couchdb_sqlite_sync/model_class/doc.dart';

class DatabaseDao {
  DatabaseProvider dbProvider;
  String dbName;

  DatabaseDao({this.dbName}) {
    dbProvider = new DatabaseProvider(dbName: dbName);
  }

  // Future<String> isExistingDoc({String id}) async {
  //   final db = await dbProvider.database;
  //   List<Map<String, dynamic>> result;

  //   result = await db.query(dbName, where: "id = ?", whereArgs: [id]);

  //   if (result.length > 0) {
  //     return result[0]['rev'].toString();
  //   }
  //   return null;
  // }

  // Future<int> createdID() async {
  //   final db = await dbProvider.database;
  //   var result = await db.query(dbName, orderBy: "id DESC", limit: 1);

  //   List<Doc> lastDoc = result.isNotEmpty
  //       ? result.map((item) => Doc.fromDatabaseJson(item)).toList()
  //       : [];

  //   return lastDoc.length == 0 ? 0 : lastDoc[0].id;
  // }

  Future<void> createDoc({Doc doc}) async {
    final db = await dbProvider.database;
    await db.rawInsert(
        'INSERT INTO $dbName(id, data, rev, revisions) VALUES(\'${doc.id}\', \'${doc.data}\', "${doc.rev}", \'${doc.revisions}\')');
  }

  Future<Doc> getDoc({String id}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;

    result = await db.query(dbName, where: 'id = ?', whereArgs: [id]);

    List<Doc> docs = result.isNotEmpty
        ? result.map((item) => Doc.fromDatabaseJson(item)).toList()
        : [];

    return docs.length == 0 ? null : docs[0];
  }

  Future<List<Doc>> getAllDocs(
      {List<String> columns, String query, String order}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;

    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(dbName,
            columns: columns,
            where: 'id LIKE ?',
            whereArgs: ["$query%"],
            orderBy: order != null ? "id $order" : null);
    } else {
      result = await db.query(dbName, columns: columns);
    }

    List<Doc> docs = result.isNotEmpty
        ? result.map((item) => Doc.fromDatabaseJson(item)).toList()
        : [];

    return docs;
  }

  Future<void> updateDoc({Doc doc}) async {
    final db = await dbProvider.database;
    await db.update(dbName, doc.toDatabaseJson(),
        where: "id = ?", whereArgs: [doc.id]);
  }

  Future<void> insertDocs({List<Doc> docs}) async {
    final db = await dbProvider.database;
    var batch = db.batch();

    for (Doc doc in docs) {
      batch.rawInsert(
          'INSERT INTO $dbName(id, data, rev, revisions) VALUES(\'${doc.id}\', \'${doc.data}\', "${doc.rev}", \'${doc.revisions}\')');
    }

    final result = await batch.commit();
    print(result);
  }

  Future<void> deleteDocs({List<String> docs}) async {
    final db = await dbProvider.database;
    var batch = db.batch();
    for (String id in docs) {
      batch.delete(dbName, where: 'id = ?', whereArgs: [id]);
    }
    final result = await batch.commit();
    print(result);
  }

  Future<void> updateDocs({List<Doc> docs}) async {
    final db = await dbProvider.database;
    var batch = db.batch();
    for (Doc doc in docs) {
      batch.update(dbName, doc.toDatabaseJson(),
          where: "id = ?", whereArgs: [doc.id]);
    }

    final result = await batch.commit();
    print(result);
  }

  Future<int> deleteDoc({String id}) async {
    final db = await dbProvider.database;
    var result = await db.delete(dbName, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future deleteAllDocs() async {
    final db = await dbProvider.database;
    var result = await db.delete(
      dbName,
    );
    return result;
  }
}
