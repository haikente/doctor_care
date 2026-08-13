import 'package:shared_preferences/shared_preferences.dart';

/// Service để lưu trữ thông tin remember me và auto login
class AuthStorageService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyUserId = 'saved_user_id';
  static const String _keyUserRole = 'saved_user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  /// Lưu trạng thái remember me và email
  static Future<void> saveRememberMe(bool rememberMe, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);
    
    if (rememberMe) {
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPassword, password);
    } else {
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);
    }
  }
  
  /// Lưu thông tin đăng nhập để auto login
  static Future<void> saveLoginSession({
    required String odLoginUser,
    required String email,
    required String role,
    required bool rememberMe,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, odLoginUser);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyUserRole, role);
      await prefs.setBool(_keyRememberMe, true);
      if (password != null && password.isNotEmpty) {
        await prefs.setString(_keyPassword, password);
      }
      print('Đã lưu phiên đăng nhập - Auto login enabled');
    } else {
      // Không ghi nhớ -> chỉ lưu email để hiển thị
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserRole);
      await prefs.setBool(_keyRememberMe, false);
    }
  }
  
  /// Kiểm tra xem có phiên đăng nhập đã lưu không
  static Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    final userId = prefs.getString(_keyUserId);
    
    return isLoggedIn && rememberMe && userId != null && userId.isNotEmpty;
  }
  
  /// Lấy thông tin user đã lưu để auto login
  static Future<Map<String, String>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    
    if (!isLoggedIn || !rememberMe) return null;
    
    final userId = prefs.getString(_keyUserId);
    final email = prefs.getString(_keyEmail);
    final role = prefs.getString(_keyUserRole);
    
    if (userId == null || email == null || role == null) return null;
    
    return {
      'userId': userId,
      'email': email,
      'role': role,
    };
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

  /// Lấy mật khẩu đã lưu để đăng nhập lại sau khi xác thực vân tay
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (rememberMe) {
      return prefs.getString(_keyPassword);
    }
    return null;
  }
  
  /// Lấy role đã lưu
  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }
  
  /// Clear tất cả data khi logout
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyIsLoggedIn);
    print('🗑️ Đã xóa tất cả dữ liệu đăng nhập');
  }

  /// Clear phiên đăng nhập khi logout nhưng vẫn giữ email/password nếu đã bật ghi nhớ
  static Future<void> clearLoginSessionOnly() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyIsLoggedIn);

    if (!rememberMe) {
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);
    }
  }
  
  /// Clear remember me data khi logout (giữ lại email nếu cần)
  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyIsLoggedIn);
  }
  
  /// Debug: In thông tin storage
  static Future<void> debugPrint() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final email = prefs.getString(_keyEmail);
    final userId = prefs.getString(_keyUserId);
    final role = prefs.getString(_keyUserRole);
    
    print('🔐 === AUTH STORAGE ===');
    print('   Remember Me: $rememberMe');
    print('   Is Logged In: $isLoggedIn');
    print('   Saved Email: ${email ?? "none"}');
    print('   Saved User ID: ${userId ?? "none"}');
    print('   Saved Role: ${role ?? "none"}');
    print('=====================');
  }
}
