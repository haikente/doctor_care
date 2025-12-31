import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/blood_pressure_model.dart';

abstract class BloodPressureDataSources {
  Future<void> addBloodPressure(BloodPressureModel bp);
  Future<void> updateBloodPressure(BloodPressureModel bp);
  Future<List<BloodPressureModel>> getAllBloodPressures();
  Future<void> deleteBloodPressure(int id);
}

class BloodPressureDataSourcesImpl implements BloodPressureDataSources {

  final dbHelper = DbHelper.instance;

  @override
  Future<void> deleteBloodPressure(int id) async{
   final db =  await dbHelper.database;
   await db.delete(
    'blood_pressure',
    where: 'id = ?',
    whereArgs: [id],
   );
  }

  @override
  Future<List<BloodPressureModel>> getAllBloodPressures() async{
    final db = await dbHelper.database;
    final result = await db.query('blood_pressure');
    return result.map((e) => BloodPressureModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateBloodPressure(BloodPressureModel bp) async{
  final db = await dbHelper.database;
  await db.update(
    'blood_pressure',
    bp.toMap(),
    where: 'id = ?',
    whereArgs: [bp.id],
  );
  }
  
  @override
  Future<void> addBloodPressure(BloodPressureModel bp) async {
    final db = await dbHelper.database;
    await db.insert('blood_pressure', bp.toMap());
  } 
}
