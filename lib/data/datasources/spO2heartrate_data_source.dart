import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/spO2heartratemodel.dart';

abstract class Spo2heartrateDataSource {
  Future<List<Spo2heartratemodel>> getAllSpo2heartrate();
  Future<void> addSpo2heartrate(Spo2heartratemodel spO2heartrate);
  Future<void> updateSpo2heartrate(Spo2heartratemodel spO2heartrate);
  Future<void> deleteSpo2heartrate(String id);
}

class Spo2heartrateDataSourceImpl implements Spo2heartrateDataSource {
  // Assume we have a database helper instance
  final dbHelper = DbHelper.instance;

  // Spo2heartrateDataSourceImpl(this.dbHelper);

  @override
  Future<void> addSpo2heartrate(Spo2heartratemodel spO2heartrate) async {
     final db = await dbHelper.database;
     await db.insert('spo2heartrate', spO2heartrate.toMap());
  }

  @override
  Future<void> deleteSpo2heartrate(String id) async {
    final db = await dbHelper.database;
    await db.delete('spo2heartrate', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Spo2heartratemodel>> getAllSpo2heartrate() async {
    final db = await dbHelper.database;
    final result = await db.query('spo2heartrate');
    return result.map((e) => Spo2heartratemodel.fromMap(e)).toList();
  }

  @override
  Future<void> updateSpo2heartrate(Spo2heartratemodel spO2heartrate) async {
    final db = await dbHelper.database;
    await db.update(
      'spo2heartrate',
      spO2heartrate.toMap(),
      where: 'id = ?',
      whereArgs: [spO2heartrate.id],
    );
  }
}