import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/bmi_weight_model.dart';

abstract class BMIWeightDataSource {
  Future<List<BMIWeightModel>> getAllBMIWeightRecords();
  Future<void> addBMIWeightRecord(BMIWeightModel record);
  Future<void> updateBMIWeightRecord(BMIWeightModel record);
  Future<void> deleteBMIWeightRecord(String id);
}

class BMIWeightDataSourceImpl implements BMIWeightDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<List<BMIWeightModel>> getAllBMIWeightRecords() async {
    final db = await dbHelper.database;
    final result = await db.query('bmi_weight', orderBy: 'timestamp DESC');
    return result.map((e) => BMIWeightModel.fromMap(e)).toList();
  }

  @override
  Future<void> addBMIWeightRecord(BMIWeightModel record) async {
    final db = await dbHelper.database;
    await db.insert('bmi_weight', record.toMap());
  }

  @override
  Future<void> updateBMIWeightRecord(BMIWeightModel record) async {
    final db = await dbHelper.database;
    await db.update(
      'bmi_weight',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  @override
  Future<void> deleteBMIWeightRecord(String id) async {
    final db = await dbHelper.database;
    await db.delete('bmi_weight', where: 'id = ?', whereArgs: [id]);
  }
}
