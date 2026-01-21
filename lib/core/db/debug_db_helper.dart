import 'package:doctor_care/core/db/db_helper.dart';

/// Debug utility để fix database issues
class DebugDbHelper {
  /// Xóa và tạo lại database hoàn toàn mới
  /// Sử dụng khi có schema mismatch
  static Future<void> recreateDatabase() async {
    print('🔧 [DEBUG] Starting database recreation...');
    try {
      await DbHelper.instance.recreateDatabase();
      print('✅ [DEBUG] Database recreated successfully!');
      print('💡 [DEBUG] Please hot restart (R) the app now.');
    } catch (e) {
      print('❌ [DEBUG] Failed to recreate database: $e');
    }
  }

  /// Kiểm tra schema hiện tại của database
  static Future<void> checkCurrentSchema() async {
    print('🔍 [DEBUG] Checking database schema...');
    try {
      await DbHelper.instance.checkSchema();
    } catch (e) {
      print('❌ [DEBUG] Failed to check schema: $e');
    }
  }
}
