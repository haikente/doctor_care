import 'package:doctor_care/core/db/db_helper.dart';
import 'package:flutter/material.dart';

/// Debug widget để fix database schema issues
class DatabaseDebugHelper extends StatelessWidget {
  const DatabaseDebugHelper({super.key});

  Future<void> _checkSchema(BuildContext context) async {
    try {
      final dbHelper = DbHelper.instance;
      await dbHelper.checkSchema();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Check console for schema'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAndRecreate(BuildContext context) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Cảnh báo'),
          content: const Text(
            'Thao tác này sẽ XÓA TẤT CẢ dữ liệu và tạo lại database với schema mới.\n\n'
            'Bạn có chắc chắn muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa & Tạo lại'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final dbHelper = DbHelper.instance;
      
      // Delete database
      await dbHelper.deleteDatabase();
      print('🗑️ Database deleted');

      // Recreate database (will happen automatically on next access)
      await dbHelper.database;
      print('✅ Database recreated with correct schema');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Database đã được tạo lại thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.bug_report,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Database Debug Tools',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nếu gặp lỗi "table temperature has no column named timestamp", '
              'sử dụng công cụ này để fix.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Check Schema Button
            ElevatedButton.icon(
              onPressed: () => _checkSchema(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('Kiểm tra Schema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Delete & Recreate Button
            ElevatedButton.icon(
              onPressed: () => _deleteAndRecreate(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Xóa & Tạo lại Database'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Lưu ý',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Xóa database sẽ MẤT TẤT CẢ dữ liệu\n'
                    '• Chỉ dùng khi development/testing\n'
                    '• Check console log để xem schema',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
