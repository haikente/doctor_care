import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/cholesterol_model.dart';

abstract class CholesterolDataSource {
  Future<void> addCholesterol(CholesterolModel record);
  Future<void> updateCholesterol(CholesterolModel record);
  Future<List<CholesterolModel>> getAllCholesterols();
  Future<void> deleteCholesterol(int id);
}

class CholesterolDataSourceImpl implements CholesterolDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<void> addCholesterol(CholesterolModel record) async {
    final db = await dbHelper.database;
    await db.insert('cholesterol', record.toMap());
  }

  @override
  Future<void> deleteCholesterol(int id) async {
    final db = await dbHelper.database;
    await db.delete('cholesterol', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CholesterolModel>> getAllCholesterols() async {
    final db = await dbHelper.database;
    final result = await db.query('cholesterol');
    return result.map((e) => CholesterolModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateCholesterol(CholesterolModel record) async {
    final db = await dbHelper.database;
    await db.update(
      'cholesterol',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
