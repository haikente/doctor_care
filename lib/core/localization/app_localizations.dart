import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get languageCode => locale.languageCode;

  // ══════════════════════════════════════
  // All translations
  // ══════════════════════════════════════
  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      // ── Navigation ──
      'home': 'Trang chủ',
      'nutrition': 'Dinh dưỡng',
      'health': 'Sức khoẻ',
      'profile': 'Cá nhân',

      // ── Profile Page ──
      'settings': 'Cài đặt',
      'personal_info': 'Thông tin cá nhân',
      'personal_info_sub': 'Cập nhật hồ sơ của bạn',
      'family_members': 'Thành viên gia đình',
      'family_members_sub': 'Quản lý hồ sơ gia đình',
      'account_security': 'Tài khoản & Bảo mật',
      'account_security_sub': 'Mật khẩu, xác thực',
      'preferences': 'Tùy chọn',
      'notifications': 'Thông báo',
      'notifications_sub': 'Quản lý nhắc nhở',
      'dark_mode': 'Chế độ tối',
      'dark_mode_on': 'Đang bật',
      'dark_mode_off': 'Đang tắt',
      'language': 'Ngôn ngữ',
      'language_vi': 'Tiếng Việt',
      'language_en': 'English',
      'support': 'Hỗ trợ',
      'help_faq': 'Trợ giúp & FAQ',
      'about_app': 'Về ứng dụng',
      'version': 'Phiên bản',
      'logout': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
      'cancel': 'Hủy',
      'user': 'Người dùng',
      'choose_language': 'Chọn ngôn ngữ',

      // ── Quick Stats ──
      'health_status': 'Sức khoẻ',
      'good': 'Tốt',
      'meals': 'Bữa ăn',
      'today': 'Hôm nay',
      'steps': 'Bước chân',
      'tracking': 'Đang theo dõi',

      // ── Photo Options ──
      'choose_from_gallery': 'Chọn từ thư viện',
      'take_photo': 'Chụp ảnh mới',
      'delete_avatar': 'Xóa ảnh đại diện',
      'uploading_photo': 'Đang tải ảnh lên...',
      'update_avatar_success': 'Cập nhật ảnh đại diện thành công!',
      'upload_failed': 'Không thể tải ảnh lên. Vui lòng thử lại!',
      'confirm': 'Xác nhận',
      'confirm_delete_avatar': 'Bạn có chắc chắn muốn xóa ảnh đại diện?',
      'delete': 'Xóa',
      'deleted_avatar': 'Đã xóa ảnh đại diện',
      'error': 'Lỗi',

      // ── Today Target ──
      'today_target': 'Mục tiêu hôm nay',
      'drink_water': 'Uống nước',
      'step_count': 'Bước chân',
      'meal_calories': 'Bữa ăn',
      'step_goal': '10.000 bước',
      'water_goal': '2000 ml',
      'calorie_goal': '2000 kcal',

      // ── Health Page ──
      'health_tracking': 'Theo dõi sức khoẻ tổng quát',
      'health_metrics': 'Các chỉ số sức khoẻ',
      'health_advice': 'Lời khuyên sức khoẻ',

      // ── Nutrition Page ──
      'nutrition_distribution': 'Phân bổ dinh dưỡng',
      'today_meals': 'Bữa ăn hôm nay',
      'no_meals_today': 'Chưa có bữa ăn nào',
      'add_meal_hint': 'Thêm bữa ăn để theo dõi dinh dưỡng',
      'nutrition_summary': 'Tổng kết dinh dưỡng',
      'add_new_dish': 'Thêm mới món ăn',

      // ── Meal Capture ──
      'ai_analyzing': 'AI đang nhận diện thành phần dinh dưỡng',
      'nutrition_analysis_ai': 'Phân tích dinh dưỡng\nbằng AI',
      'capture_hint':
          'Chụp ảnh hoặc chọn ảnh bữa ăn, AI sẽ nhận diện\nvà phân tích thông tin dinh dưỡng chi tiết.',
      'fast_recognition': 'Nhận diện nhanh',
      'detailed_calories': 'Chi tiết calo',
      'food_database': '852+ thực phẩm',
      'take_photo_btn': 'Chụp ảnh bữa ăn',
      'choose_from_gallery_btn': 'Chọn từ thư viện',

      // ── Meal Detail ──
      'food_items': 'Thành phần thực phẩm',
      'health_recommendations': 'Lời khuyên sức khoẻ',
      'notes': 'Ghi chú',
      'delete_meal': 'Xóa bữa ăn',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',
      'fiber': 'Chất xơ',
      'calories': 'Calo',
      'glycemic_index': 'Chỉ số GI',

      // ── Common ──
      'save': 'Lưu',
      'search': 'Tìm kiếm',
      'loading': 'Đang tải...',
      'no_data': 'Không có dữ liệu',
    },
    'en': {
      // ── Navigation ──
      'home': 'Home',
      'nutrition': 'Nutrition',
      'health': 'Health',
      'profile': 'Profile',

      // ── Profile Page ──
      'settings': 'Settings',
      'personal_info': 'Personal Info',
      'personal_info_sub': 'Update your profile',
      'family_members': 'Family Members',
      'family_members_sub': 'Manage family profiles',
      'account_security': 'Account & Security',
      'account_security_sub': 'Password, authentication',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'notifications_sub': 'Manage reminders',
      'dark_mode': 'Dark Mode',
      'dark_mode_on': 'On',
      'dark_mode_off': 'Off',
      'language': 'Language',
      'language_vi': 'Tiếng Việt',
      'language_en': 'English',
      'support': 'Support',
      'help_faq': 'Help & FAQ',
      'about_app': 'About App',
      'version': 'Version',
      'logout': 'Log out',
      'logout_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'user': 'User',
      'choose_language': 'Choose Language',

      // ── Quick Stats ──
      'health_status': 'Health',
      'good': 'Good',
      'meals': 'Meals',
      'today': 'Today',
      'steps': 'Steps',
      'tracking': 'Tracking',

      // ── Photo Options ──
      'choose_from_gallery': 'Choose from gallery',
      'take_photo': 'Take a photo',
      'delete_avatar': 'Delete avatar',
      'uploading_photo': 'Uploading photo...',
      'update_avatar_success': 'Avatar updated successfully!',
      'upload_failed': 'Upload failed. Please try again!',
      'confirm': 'Confirm',
      'confirm_delete_avatar': 'Are you sure you want to delete your avatar?',
      'delete': 'Delete',
      'deleted_avatar': 'Avatar deleted',
      'error': 'Error',

      // ── Today Target ──
      'today_target': 'Today\'s Target',
      'drink_water': 'Water Intake',
      'step_count': 'Steps',
      'meal_calories': 'Meals',
      'step_goal': '10,000 steps',
      'water_goal': '2000 ml',
      'calorie_goal': '2000 kcal',

      // ── Health Page ──
      'health_tracking': 'General health tracking',
      'health_metrics': 'Health Metrics',
      'health_advice': 'Health Advice',

      // ── Nutrition Page ──
      'nutrition_distribution': 'Nutrition Distribution',
      'today_meals': 'Today\'s Meals',
      'no_meals_today': 'No meals yet',
      'add_meal_hint': 'Add a meal to track nutrition',
      'nutrition_summary': 'Nutrition Summary',
      'add_new_dish': 'Add New Dish',

      // ── Meal Capture ──
      'ai_analyzing': 'AI is identifying nutritional content',
      'nutrition_analysis_ai': 'Nutrition Analysis\nby AI',
      'capture_hint':
          'Take or select a photo of your meal, AI will identify\nand analyze detailed nutritional information.',
      'fast_recognition': 'Fast recognition',
      'detailed_calories': 'Detailed calories',
      'food_database': '852+ foods',
      'take_photo_btn': 'Take meal photo',
      'choose_from_gallery_btn': 'Choose from gallery',

      // ── Meal Detail ──
      'food_items': 'Food Items',
      'health_recommendations': 'Health Recommendations',
      'notes': 'Notes',
      'delete_meal': 'Delete Meal',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',
      'fiber': 'Fiber',
      'calories': 'Calories',
      'glycemic_index': 'GI Index',

      // ── Common ──
      'save': 'Save',
      'search': 'Search',
      'loading': 'Loading...',
      'no_data': 'No data',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['vi']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
