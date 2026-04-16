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
  static Future<void> exportDatabase(BuildContext context) async {
    try {
      // 1. Lấy đường dẫn của DB hiện tại
      final dbFolder = await getDatabasesPath();
      final sourcePath = join(dbFolder, 'doctor_care.db');
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

      // 2. Tạo bản copy sang thư mục tạm để Share (Share plugin yêu cầu file phải ở Cache/Temp)
      final tempDir = await getTemporaryDirectory();
      // Đặt tên có kèm timestamp để dễ phân biệt
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '')
          .split('.')[0];
      final backupFileName = 'doctor_care_backup_$timestamp.db';
      final tempBackupPath = join(tempDir.path, backupFileName);

      await sourceFile.copy(tempBackupPath);

      // 3. Sử dụng Share Plus để xuất file ra ngoài
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
    }
  }

  static Future<bool> importDatabase(BuildContext context) async {
    try {
      // 1. Cho phép người dùng chọn file backup
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType
            .any, // Ở Android đôi khi FileType.custom không hoạt động tốt với .db
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final sourceFile = File(filePath);

        // Kiểm tra cơ bản xem file có vẻ hợp lệ không (đuôi .db hoặc dung lượng > 0)
        if (!filePath.endsWith('.db') && !filePath.endsWith('.bak')) {
          // Chỉ cảnh báo, vẫn cho qua vì người dùng có thể đổi tên file
          print('Cảnh báo: File không có đuôi .db chuẩn.');
        }

        if (await sourceFile.length() == 0) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File sao lưu trống hoặc hỏng!'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }

        // 2. Lấy đường dẫn DB gốc
        final dbFolder = await getDatabasesPath();
        final targetPath = join(dbFolder, 'doctor_care.db');

        // 3. Ngắt kết nối DB hiện tại an toàn
        await DbHelper.instance.closeDatabase();

        // 4. Ghi đè file
        await sourceFile.copy(targetPath);

        // 5. Khởi tạo lại kết nối (khi gọi .database sẽ tự open lại)
        await DbHelper.instance.database;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Khôi phục dữ liệu cục bộ thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
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
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '').split('.')[0];
        final excelFileName = 'doctor_care_report_$timestamp.xlsx';
        final tempExcelPath = join(tempDir.path, excelFileName);

        File(tempExcelPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

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
