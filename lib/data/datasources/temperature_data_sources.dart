import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/temperature_model.dart';
import 'package:doctor_care/domain/entities/temperature.dart';

abstract class TemperatureDataSource {
  Future<void> insertTemperature(TemperatureModel temperature);
  Future<void> updateTemperature(TemperatureModel temperature);
  Future<void> deleteTemperature(String id);
  Future<List<Temperature>> getAllTemperatures();
}

class TemperatureDataSourceImpl implements TemperatureDataSource {
  final dbHelper = DbHelper.instance;

  @override
  Future<void> insertTemperature(TemperatureModel temperature) async {
    final db = await dbHelper.database;
    await db.insert('temperature', temperature.toMap());
  }

  @override
  Future<void> updateTemperature(TemperatureModel temperature) async {
    final db = await dbHelper.database;
    await db.update(
      'temperature',
      temperature.toMap(),
      where: 'id = ?',
      whereArgs: [temperature.id],
    );
  }

  @override
  Future<void> deleteTemperature(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'temperature',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }

  @override
  Future<List<TemperatureModel>> getAllTemperatures() async {
    final db = await dbHelper.database;
    final result = await db.query('temperature');
    return result.map((e) => TemperatureModel.fromMap(e)).toList();
  }
}
