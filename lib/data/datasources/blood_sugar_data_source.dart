import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/blood_sugar_model.dart';

abstract class BloodSugarDataSource {
  Future<void> addBloodSugar(BloodSugarModel record);
  Future<void> updateBloodSugar(BloodSugarModel record);
  Future<List<BloodSugarModel>> getAllBloodSugars();
  Future<void> deleteBloodSugar(int id);
}

class BloodSugarDataSourceImpl implements BloodSugarDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<void> addBloodSugar(BloodSugarModel record) async {
    final db = await dbHelper.database;
    await db.insert('blood_sugar', record.toMap());
  }

  @override
  Future<void> deleteBloodSugar(int id) async {
    final db = await dbHelper.database;
    await db.delete('blood_sugar', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<BloodSugarModel>> getAllBloodSugars() async {
    final db = await dbHelper.database;
    final result = await db.query('blood_sugar');
    return result.map((e) => BloodSugarModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateBloodSugar(BloodSugarModel record) async {
    final db = await dbHelper.database;
    await db.update(
      'blood_sugar',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
