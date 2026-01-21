import 'package:shared_preferences/shared_preferences.dart';

/// Service để lưu trữ thông tin remember me
class AuthStorageService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'saved_email';
  
  /// Lưu trạng thái remember me và email
  static Future<void> saveRememberMe(bool rememberMe, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);
    
    if (rememberMe) {
      await prefs.setString(_keyEmail, email);
    } else {
      await prefs.remove(_keyEmail);
    }
  }
  
  /// Lấy trạng thái remember me
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }
  
  /// Lấy email đã lưu
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    
    if (rememberMe) {
      return prefs.getString(_keyEmail);
    }
    return null;
  }
  
  /// Clear remember me data khi logout
  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyEmail);
  }
  
  /// Debug: In thông tin storage
  static Future<void> debugPrint() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    final email = prefs.getString(_keyEmail);
    
    print('🔐 === AUTH STORAGE ===');
    print('   Remember Me: $rememberMe');
    print('   Saved Email: ${email ?? "none"}');
    print('=====================');
  }
}
