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
    'step_count',
    'family_profile',
  };

  static String _timestampForFileName() {
    return DateTime.now().toIso8601String().replaceAll(':', '').split('.')[0];
  }

  static String _databasePath(String dbFolder) {
    return join(dbFolder, DbHelper.dbName);
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
      return 'File sao lưu trống hoặc hỏng!';
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
      // 1. Lấy đường dẫn của DB hiện tại
      final dbFolder = await getDatabasesPath();
      final sourcePath = _databasePath(dbFolder);
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy cơ sở dữ liệu để xuất!'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      try {
        await DbHelper.instance.database;
      } catch (_) {}
    }
  }

  static Future<bool> importDatabase(BuildContext context) async {
    try {

      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType
            .any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final sourceFile = File(filePath);

        final currentVersion = DbHelper.dbVersion;

        final validationError = await _validateBackupFile(
          filePath,
          maxSupportedVersion: currentVersion,
        );
        if (validationError != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationError),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }

        // 2. Lấy đường dẫn DB gốc + chuẩn bị rollback file
        final dbFolder = await getDatabasesPath();
        final targetPath = _databasePath(dbFolder);
        final rollbackPath = join(
          dbFolder,
          'doctor_care_before_restore_${_timestampForFileName()}.db',
        );
        final targetFile = File(targetPath);
        final rollbackFile = File(rollbackPath);
        var rollbackReady = false;

        try {
          // 3. Ngắt kết nối DB hiện tại an toàn
          await DbHelper.instance.closeDatabase();

          // 4. Tạo rollback point trước khi ghi đè
          if (await targetFile.exists()) {
            await targetFile.copy(rollbackPath);
            rollbackReady = true;
            await targetFile.delete();
          }

          // 5. Ghi đè file
          await sourceFile.copy(targetPath);

          // 6. Khởi tạo lại kết nối và verify sau restore
          final restoredDb = await DbHelper.instance.database;
          final postRestoreError = await _validateDoctorCareDatabase(
            restoredDb,
            maxSupportedVersion: currentVersion,
          );
          if (postRestoreError != null) {
            throw Exception(postRestoreError);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Khôi phục dữ liệu cục bộ thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return true;
        } catch (restoreError) {
          // 7. Tự động rollback nếu restore thất bại
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

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Khôi phục thất bại và đã rollback dữ liệu cũ: $restoreError',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        } finally {
          if (await rollbackFile.exists()) {
            try {
              await rollbackFile.delete();
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khôi phục: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return false;
  }

  /// Exports the SQLite database to a multi-sheet Excel file (.xlsx)
  static Future<void> exportToExcel(BuildContext context) async {
    try {
      final db = await DbHelper.instance.database;
      var excel = Excel.createExcel();

      // Retrieve all actual tables (excluding sqlite internal tables)
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      bool isFirstSheet = true;

      for (var tableRow in tables) {
        String tableName = tableRow['name'] as String;
        final rows = await db.query(tableName);

        if (rows.isEmpty) continue; // Skip empty tables
        
        // Ensure android safe table names (excel sheet names max 31 chars usually but we are fine)
        final columns = rows.first.keys.toList();

        Sheet sheetObject;
        if (isFirstSheet) {
          excel.rename('Sheet1', tableName);
          sheetObject = excel[tableName];
          isFirstSheet = false;
        } else {
          sheetObject = excel[tableName];
        }

        // Insert Header Row
        for (int i = 0; i < columns.length; i++) {
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = TextCellValue(columns[i]);
        }

        // Insert Data Rows
        for (int r = 0; r < rows.length; r++) {
          final rowData = rows[r];
          for (int c = 0; c < columns.length; c++) {
            var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
            final value = rowData[columns[c]];

            if (value != null) {
              if (value is int) {
                cell.value = IntCellValue(value);
              } else if (value is double) {
                cell.value = DoubleCellValue(value);
              } else {
                cell.value = TextCellValue(value.toString());
              }
            }
          }
        }
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
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
            text: 'Báo cáo Dữ liệu Y tế Doctor Care (Excel)',
            subject: 'Doctor Care Excel Report',
            sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tạo file báo cáo!'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất Excel: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
