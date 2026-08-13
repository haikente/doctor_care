// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:doctor_care/core/db/db_helper.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class AdminBackupService {
  static const _requiredTablesForBackup = <String>{
    'hba1c',
    'blood_pressure',
    'temperature',
    'spo2heartrate',
    'bmi_weight',
    'water_intake',
    'blood_sugar',
    'sleep_record',
    'step_count',
    'cholesterol',
    'family_profile',
    'creatinine',
    'menstrual_cycle',
  };

  static String _timestampForFileName() {
    return DateTime.now().toIso8601String().replaceAll(':', '').split('.')[0];
  }

  static String _databasePath(String dbFolder) {
    return join(dbFolder, DbHelper.dbName);
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color color,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  static Future<void> _checkpointActiveDatabase() async {
    try {
      final db = await DbHelper.instance.database;
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    } catch (_) {
      // Older SQLite builds or journal modes can ignore this safely.
    }
  }

  static Future<String?> _validateDoctorCareDatabase(
    Database db, {
    required int maxSupportedVersion,
  }) async {
    final dbVersion = await db.getVersion();
    if (dbVersion > maxSupportedVersion) {
      return 'File backup thuộc phiên bản mới hơn ứng dụng hiện tại '
          '(v$dbVersion > v$maxSupportedVersion).';
    }

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name NOT LIKE 'sqlite_%'",
    );
    final tableNames = tables
        .map((row) => '${row['name'] ?? ''}'.toLowerCase())
        .toSet();

    final missing = _requiredTablesForBackup
        .where((table) => !tableNames.contains(table))
        .toList();
    if (missing.isNotEmpty) {
      return 'File backup không đúng định dạng Doctor Care '
          '(thiếu bảng: ${missing.join(', ')}).';
    }

    final integrity = await db.rawQuery('PRAGMA integrity_check');
    final integrityResult = integrity.isNotEmpty
        ? '${integrity.first.values.first ?? ''}'.toLowerCase()
        : '';
    if (integrityResult != 'ok') {
      return 'File backup bị lỗi integrity_check ($integrityResult).';
    }

    return null;
  }

  static Future<String?> _validateBackupFile(
    String filePath, {
    required int maxSupportedVersion,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return 'Không tìm thấy file sao lưu đã chọn.';
    }
    if (await file.length() == 0) {
      return 'File sao lưu trống hoặc hỏng.';
    }

    Database? readOnlyDb;
    try {
      readOnlyDb = await openDatabase(
        filePath,
        readOnly: true,
        singleInstance: false,
      );

      return _validateDoctorCareDatabase(
        readOnlyDb,
        maxSupportedVersion: maxSupportedVersion,
      );
    } on DatabaseException {
      return 'File đã chọn không phải cơ sở dữ liệu SQLite hợp lệ.';
    } finally {
      if (readOnlyDb != null && readOnlyDb.isOpen) {
        await readOnlyDb.close();
      }
    }
  }

  static Future<void> exportDatabase(BuildContext context) async {
    try {
      await _checkpointActiveDatabase();

      final dbFolder = await getDatabasesPath();
      final sourcePath = _databasePath(dbFolder);
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        _showSnackBar(
          context,
          message: 'Không tìm thấy cơ sở dữ liệu để xuất.',
          color: Colors.red,
        );
        return;
      }

      await DbHelper.instance.closeDatabase();

      final tempDir = await getTemporaryDirectory();
      final timestamp = _timestampForFileName();
      final backupFileName = 'doctor_care_backup_$timestamp.db';
      final tempBackupPath = join(tempDir.path, backupFileName);

      await sourceFile.copy(tempBackupPath);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(tempBackupPath)],
          text: 'Bản sao lưu Doctor Care DB',
          subject: 'Doctor Care Backup',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );
      }
    } catch (e) {
      _showSnackBar(
        context,
        message: 'Lỗi xuất dữ liệu: $e',
        color: Colors.red,
      );
    } finally {
      try {
        await DbHelper.instance.database;
      } catch (_) {}
    }
  }

  static Future<bool> importDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final filePath = result.files.single.path!;
      final sourceFile = File(filePath);
      final currentVersion = DbHelper.dbVersion;

      final validationError = await _validateBackupFile(
        filePath,
        maxSupportedVersion: currentVersion,
      );
      if (validationError != null) {
        _showSnackBar(context, message: validationError, color: Colors.red);
        return false;
      }

      final dbFolder = await getDatabasesPath();
      final targetPath = _databasePath(dbFolder);
      if (normalize(absolute(filePath)) == normalize(absolute(targetPath))) {
        _showSnackBar(
          context,
          message: 'Không thể khôi phục từ chính file database đang sử dụng.',
          color: Colors.red,
        );
        return false;
      }

      final rollbackPath = join(
        dbFolder,
        'doctor_care_before_restore_${_timestampForFileName()}.db',
      );
      final targetFile = File(targetPath);
      final rollbackFile = File(rollbackPath);
      var rollbackReady = false;

      try {
        await _checkpointActiveDatabase();
        await DbHelper.instance.closeDatabase();

        if (await targetFile.exists()) {
          await targetFile.copy(rollbackPath);
          rollbackReady = true;
          await targetFile.delete();
        }

        await sourceFile.copy(targetPath);

        final restoredDb = await DbHelper.instance.database;
        final postRestoreError = await _validateDoctorCareDatabase(
          restoredDb,
          maxSupportedVersion: currentVersion,
        );
        if (postRestoreError != null) {
          throw Exception(postRestoreError);
        }

        _showSnackBar(
          context,
          message: 'Khôi phục dữ liệu cục bộ thành công.',
          color: Colors.green,
        );
        return true;
      } catch (restoreError) {
        try {
          await DbHelper.instance.closeDatabase();

          if (rollbackReady && await rollbackFile.exists()) {
            if (await targetFile.exists()) {
              await targetFile.delete();
            }
            await rollbackFile.copy(targetPath);
          }

          await DbHelper.instance.database;
        } catch (_) {}

        _showSnackBar(
          context,
          message:
              'Khôi phục thất bại và đã rollback dữ liệu cũ: $restoreError',
          color: Colors.red,
        );
        return false;
      } finally {
        if (await rollbackFile.exists()) {
          try {
            await rollbackFile.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      _showSnackBar(context, message: 'Lỗi khôi phục: $e', color: Colors.red);
    }

    return false;
  }

  /// Exports the SQLite database to a multi-sheet Excel file (.xlsx).
  static Future<void> exportToExcel(BuildContext context) async {
    try {
      final db = await DbHelper.instance.database;
      final excel = Excel.createExcel();

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%'",
      );

      var isFirstSheet = true;

      for (final tableRow in tables) {
        final tableName = tableRow['name'] as String;
        final rows = await db.query(tableName);

        if (rows.isEmpty) continue;

        final columns = rows.first.keys.toList();

        final Sheet sheetObject;
        if (isFirstSheet) {
          excel.rename('Sheet1', tableName);
          sheetObject = excel[tableName];
          isFirstSheet = false;
        } else {
          sheetObject = excel[tableName];
        }

        for (var i = 0; i < columns.length; i++) {
          final cell = sheetObject.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          );
          cell.value = TextCellValue(columns[i]);
        }

        for (var r = 0; r < rows.length; r++) {
          final rowData = rows[r];
          for (var c = 0; c < columns.length; c++) {
            final cell = sheetObject.cell(
              CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
            );
            final value = rowData[columns[c]];

            if (value is int) {
              cell.value = IntCellValue(value);
            } else if (value is double) {
              cell.value = DoubleCellValue(value);
            } else if (value != null) {
              cell.value = TextCellValue(value.toString());
            }
          }
        }
      }

      final fileBytes = excel.save();
      if (fileBytes == null) {
        _showSnackBar(
          context,
          message: 'Không thể tạo file báo cáo.',
          color: Colors.red,
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = _timestampForFileName();
      final excelFileName = 'doctor_care_report_$timestamp.xlsx';
      final tempExcelPath = join(tempDir.path, excelFileName);

      final outFile = File(tempExcelPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(fileBytes, flush: true);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(tempExcelPath)],
          text: 'Báo cáo dữ liệu y tế Doctor Care (Excel)',
          subject: 'Doctor Care Excel Report',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );
      }
    } catch (e) {
      _showSnackBar(context, message: 'Lỗi xuất Excel: $e', color: Colors.red);
    }
  }
}
