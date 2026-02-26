import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/step_count_model.dart';

abstract class StepCountDataSource {
  Future<void> addStepCount(StepCountModel record);
  Future<void> updateStepCount(StepCountModel record);
  Future<List<StepCountModel>> getAllStepCounts();
  Future<void> deleteStepCount(int id);
}

class StepCountDataSourceImpl implements StepCountDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<void> addStepCount(StepCountModel record) async {
    final db = await dbHelper.database;
    await db.insert('step_count', record.toMap());
  }

  @override
  Future<void> deleteStepCount(int id) async {
    final db = await dbHelper.database;
    await db.delete('step_count', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<StepCountModel>> getAllStepCounts() async {
    final db = await dbHelper.database;
    final result = await db.query('step_count');
    return result.map((e) => StepCountModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateStepCount(StepCountModel record) async {
    final db = await dbHelper.database;
    await db.update(
      'step_count',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
