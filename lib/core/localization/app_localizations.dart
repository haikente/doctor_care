import 'package:flutter/foundation.dart';
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

  static const List<String> supportedLanguageCodes = ['vi', 'en'];
  static const List<Locale> supportedLocales = [Locale('vi'), Locale('en')];

  String get languageCode => locale.languageCode.toLowerCase();

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

      // ── Meal Analysis ──
      'meal_analysis_result_title': 'Kết quả phân tích',
      'meal_analysis_need_food_item_to_save': 'Cần có ít nhất 1 món ăn để lưu!',
      'meal_analysis_save_error': 'Lỗi khi lưu: {error}',
      'meal_analysis_saved_success': 'Đã lưu bữa ăn thành công!',
      'meal_capture_title': 'Phân tích bữa ăn',
      'analyzing_meal': 'Đang phân tích bữa ăn...',
      'dish_name_label': 'Tên món ăn',
      'dish_name_hint': 'Nhập tên món ăn',
      'overview': 'Tổng quan',
      'total_calories': 'Tổng calo',
      'tap_to_edit': 'Chạm để chỉnh sửa',
      'save_meal': 'Lưu bữa ăn',
      'edit_food_item': 'Chỉnh sửa: {name}',
      'portion_grams_label': 'Khối lượng (gram)',
      'nutrition_recalc_note': 'Giá trị dinh dưỡng sẽ được tính lại theo tỷ lệ',

      // ── Auth ──
      'forgot_password_title': 'Quên mật khẩu',
      'reset_password_title': 'Đặt lại mật khẩu',
      'reset_password_desc':
          'Nhập email của bạn để nhận liên kết đặt lại mật khẩu. Chúng tôi sẽ gửi hướng dẫn đến địa chỉ email này.',
      'email': 'Email',
      'your_email_hint': 'Email của bạn',
      'please_enter_email': 'Vui lòng nhập email',
      'invalid_email_format': 'Email không đúng định dạng',
      'send_reset_link': 'Gửi liên kết đặt lại',
      'back_to_login': 'Quay lại đăng nhập',
      'reset_email_sent':
          'Email khôi phục mật khẩu đã được gửi! Vui lòng kiểm tra hộp thư.',
      'note': 'Lưu ý:',
      'reset_password_note_bullets':
          '• Kiểm tra cả hộp thư spam/junk\n• Liên kết có hiệu lực trong 1 giờ\n• Nếu không nhận được email, thử lại sau 5 phút',

      // ── Common ──
      'save': 'Lưu',
      'search': 'Tìm kiếm',
      'loading': 'Đang tải...',
      'no_data': 'Không có dữ liệu',
      'error_with_message': 'Lỗi: {message}',

      'time': 'Thời gian',
      'status': 'Trạng thái',
      'classification': 'Phân loại',
      'clear_filter': 'Xóa bộ lọc',
      'record_count': '{count} bản ghi',
      'retry': 'Thử lại',
      'add': 'Thêm',
      'close': 'Đóng',
      'not_selected': 'Chưa chọn',
      'no_results_found': 'Không tìm thấy kết quả',
      'try_change_filters': 'Thử thay đổi bộ lọc của bạn',
      'no_data_for_filter': 'Không có dữ liệu cho bộ lọc này',
      'no_data_matching_filter': 'Không có dữ liệu phù hợp với bộ lọc',
      'activity_level': 'Mức vận động',
      'activity_low': 'Ít vận động',
      'activity_moderate': 'Vừa phải',
      'activity_active': 'Năng động',
      'bmi_underweight': 'Thiếu cân',
      'bmi_overweight': 'Thừa cân',
      'bmi_obese': 'Béo phì',
      'blood_sugar_status': 'Trạng thái đường huyết',
      'blood_sugar_low': 'Hạ đường huyết',
      'blood_sugar_prediabetes_short': 'Tiền ĐTĐ',
      'blood_sugar_prediabetes': 'Tiền đái tháo đường',
      'blood_sugar_diabetes': 'Đái tháo đường',
      'measurement_time': 'Thời điểm đo',
      'before_sleep': 'Trước ngủ',
      'after_wake': 'Sau ngủ dậy',
      'sleep_duration': 'Thời lượng ngủ',
      'sleep_quality': 'Chất lượng',
      'sleep_duration_severe_shortage': 'Thiếu ngủ N.trọng',
      'sleep_duration_severe_shortage_full': 'Thiếu ngủ nghiêm trọng',
      'sleep_duration_shortage': 'Thiếu ngủ',
      'sleep_duration_ok': 'Tạm đủ',
      'sleep_duration_good': 'Tốt',
      'filter_results': 'Lọc kết quả',
      'filter': 'Bộ lọc',
      'all': 'Tất cả',
      'manual_entry': 'Nhập tay',
      'device': 'Thiết bị',
      'status_normal': 'Bình thường',
      'status_monitoring': 'Theo dõi',
      'status_attention': 'Cần chú ý',
      'status_danger': 'Nguy hiểm',
      'apply': 'Áp dụng',
      'date_range_invalid': 'Ngày bắt đầu phải trước ngày kết thúc',
      'temp_low': 'Hạ nhiệt',
      'temp_mild_fever': 'Sốt nhẹ',
      'temp_moderate_fever': 'Sốt vừa',
      'temp_high_fever': 'Sốt cao',
      'no_step_data': 'Không có dữ liệu bước chân',
      'no_sleep_data': 'Không có dữ liệu giấc ngủ',
      'no_blood_sugar_data': 'Không có dữ liệu đường huyết',
      'no_cholesterol_data': 'Không có dữ liệu cholesterol',
      'no_blood_pressure_data': 'Không có dữ liệu huyết áp',
      'no_hba1c_data': 'Không có dữ liệu HbA1c',
      'steps_unit': 'bước',
      'meal_status_fasting': 'Lúc đói',
      'meal_status_before_meal': 'Trước ăn',
      'meal_status_after_meal': 'Sau ăn 2h',
      'meal_status_random': 'Ngẫu nhiên',

      // ── Notifications ──
      'notifications_title': 'Thông báo',
      'unread_count': '{count} chưa đọc',
      'mark_all': 'Đánh dấu tất cả',
      'deleted_notification': 'Đã xóa thông báo',
      'filter_unread': 'Chưa đọc',
      'filter_read': 'Đã đọc',
      'no_unread_notifications': 'Không có thông báo chưa đọc',

      // ── Meal history ──
      'meal_history_title': 'Lịch sử bữa ăn',
      'ai_analyze': 'AI phân tích',
      'no_meals_in_range': 'Không có bữa ăn nào trong khoảng thời gian này',
      'try_another_range': 'Thử chọn khoảng thời gian khác',
      'tap_ai_to_start': 'Nhấn nút "AI phân tích" để bắt đầu',
      'week': 'Tuần',
      'month': 'Tháng',

      // ── Insert dish (manual meal) ──
      'add_new_meal_title': 'Thêm mới món ăn',
      'dish_name_section': 'Tên món ăn',
      'dish_name_example_hint': 'VD: Phở Bò, Cơm Tấm...',
      'search_food_hint': 'Tìm kiếm thực phẩm...',
      'meal_notes_hint_optional': 'Ghi chú về bữa ăn (tùy chọn)...',
      'per_100g': 'Trên 100g',
      'please_add_at_least_one_food': 'Vui lòng thêm ít nhất 1 thực phẩm',
      'default_meal_name': 'Bữa ăn',
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

      // ── Meal Analysis ──
      'meal_analysis_result_title': 'Analysis Result',
      'meal_analysis_need_food_item_to_save':
          'Add at least 1 food item to save!',
      'meal_analysis_save_error': 'Save failed: {error}',
      'meal_analysis_saved_success': 'Meal saved successfully!',
      'meal_capture_title': 'Meal analysis',
      'analyzing_meal': 'Analyzing meal...',
      'dish_name_label': 'Dish name',
      'dish_name_hint': 'Enter dish name',
      'overview': 'Overview',
      'total_calories': 'Total calories',
      'tap_to_edit': 'Tap to edit',
      'save_meal': 'Save meal',
      'edit_food_item': 'Edit: {name}',
      'portion_grams_label': 'Portion (grams)',
      'nutrition_recalc_note': 'Nutrition values will be recalculated by ratio',

      // ── Auth ──
      'forgot_password_title': 'Forgot password',
      'reset_password_title': 'Reset password',
      'reset_password_desc':
          'Enter your email to receive a password reset link. We will send instructions to this email address.',
      'email': 'Email',
      'your_email_hint': 'Your email',
      'please_enter_email': 'Please enter your email',
      'invalid_email_format': 'Invalid email format',
      'send_reset_link': 'Send reset link',
      'back_to_login': 'Back to login',
      'reset_email_sent':
          'Password reset email sent. Please check your inbox.',
      'note': 'Note:',
      'reset_password_note_bullets':
          '• Also check spam/junk folder\n• Link is valid for 1 hour\n• If you don\'t receive the email, try again after 5 minutes',

      // ── Common ──
      'save': 'Save',
      'search': 'Search',
      'loading': 'Loading...',
      'no_data': 'No data',
      'error_with_message': 'Error: {message}',

      'time': 'Time',
      'status': 'Status',
      'classification': 'Classification',
      'clear_filter': 'Clear filters',
      'record_count': '{count} records',
      'retry': 'Try again',
      'add': 'Add',
      'close': 'Close',
      'not_selected': 'Not selected',
      'no_results_found': 'No results found',
      'try_change_filters': 'Try changing your filters',
      'no_data_for_filter': 'No data for this filter',
      'no_data_matching_filter': 'No data matching the filter',
      'activity_level': 'Activity level',
      'activity_low': 'Low',
      'activity_moderate': 'Moderate',
      'activity_active': 'Active',
      'bmi_underweight': 'Underweight',
      'bmi_overweight': 'Overweight',
      'bmi_obese': 'Obese',
      'blood_sugar_status': 'Blood sugar status',
      'blood_sugar_low': 'Low blood sugar',
      'blood_sugar_prediabetes_short': 'Pre-DM',
      'blood_sugar_prediabetes': 'Prediabetes',
      'blood_sugar_diabetes': 'Diabetes',
      'measurement_time': 'Measurement time',
      'before_sleep': 'Before sleep',
      'after_wake': 'After waking',
      'sleep_duration': 'Sleep duration',
      'sleep_quality': 'Quality',
      'sleep_duration_severe_shortage': 'Severe shortage',
      'sleep_duration_severe_shortage_full': 'Severe sleep shortage',
      'sleep_duration_shortage': 'Shortage',
      'sleep_duration_ok': 'Okay',
      'sleep_duration_good': 'Good',
      'filter_results': 'Filter results',
      'filter': 'Filter',
      'all': 'All',
      'manual_entry': 'Manual',
      'device': 'Device',
      'status_normal': 'Normal',
      'status_monitoring': 'Monitoring',
      'status_attention': 'Needs attention',
      'status_danger': 'Danger',
      'apply': 'Apply',
      'date_range_invalid': 'Start date must be before end date',
      'temp_low': 'Low temperature',
      'temp_mild_fever': 'Mild fever',
      'temp_moderate_fever': 'Moderate fever',
      'temp_high_fever': 'High fever',
      'no_step_data': 'No step data',
      'no_sleep_data': 'No sleep data',
      'no_blood_sugar_data': 'No blood sugar data',
      'no_cholesterol_data': 'No cholesterol data',
      'no_blood_pressure_data': 'No blood pressure data',
      'no_hba1c_data': 'No HbA1c data',
      'steps_unit': 'steps',
      'meal_status_fasting': 'Fasting',
      'meal_status_before_meal': 'Before meal',
      'meal_status_after_meal': '2h after meal',
      'meal_status_random': 'Random',

      // ── Notifications ──
      'notifications_title': 'Notifications',
      'unread_count': '{count} unread',
      'mark_all': 'Mark all',
      'deleted_notification': 'Notification deleted',
      'filter_unread': 'Unread',
      'filter_read': 'Read',
      'no_unread_notifications': 'No unread notifications',

      // ── Meal history ──
      'meal_history_title': 'Meal history',
      'ai_analyze': 'AI analyze',
      'no_meals_in_range': 'No meals in this time range',
      'try_another_range': 'Try a different time range',
      'tap_ai_to_start': 'Tap "AI analyze" to get started',
      'week': 'Week',
      'month': 'Month',

      // ── Insert dish (manual meal) ──
      'add_new_meal_title': 'Add new meal',
      'dish_name_section': 'Dish name',
      'dish_name_example_hint': 'e.g., Pho, Rice plate...',
      'search_food_hint': 'Search foods...',
      'meal_notes_hint_optional': 'Meal notes (optional)...',
      'per_100g': 'Per 100g',
      'please_add_at_least_one_food': 'Please add at least 1 food item',
      'default_meal_name': 'Meal',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    final normalizedCode = languageCode;
    final raw = _localizedValues[normalizedCode]?[key] ??
        _localizedValues['vi']?[key] ??
        key;

    if (params == null || params.isEmpty) return raw;

    var out = raw;
    for (final entry in params.entries) {
      out = out.replaceAll('{${entry.key}}', entry.value);
    }
    return out;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLanguageCodes
          .contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) {
    // No async work needed; keep localization load synchronous.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key, {Map<String, String>? params}) =>
      AppLocalizations.of(this).translate(key, params: params);
}
