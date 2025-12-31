import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/data/models/hba1c_model.dart';

abstract class Hba1cDataSources {
  Future<List<Hba1cModel>> getAllHba1c();
  Future<void> addHba1c(Hba1cModel hba1cModel);
  Future<void> updateHba1c(Hba1cModel hba1cModel);
  Future<void> deleteHba1c(int id);
}

class Hba1cDataSourcesImpl implements Hba1cDataSources {

  final dbHelper = DbHelper.instance;
  
  @override
  Future<void> addHba1c(Hba1cModel hba1cModel) async {
    final db = await dbHelper.database;
    await db.insert('hba1c', hba1cModel.toMap());
  }
  
  
  @override
  Future<List<Hba1cModel>> getAllHba1c() async{
    final db = await dbHelper.database;
    final result = await db.query('hba1c');
    return result.map((e) => Hba1cModel.fromMap(e)).toList();
  }
  
  @override
  Future<void> updateHba1c(Hba1cModel hba1cModel) async {
    final db = await dbHelper.database;
    await db.update(
      'hba1c',
      hba1cModel.toMap(),
      where: 'id = ?',
      whereArgs: [hba1cModel.id],
    );
  }

  @override
  Future<void> deleteHba1c(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'hba1c',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}