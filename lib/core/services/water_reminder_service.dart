import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class WaterReminderService {
  static final WaterReminderService instance = WaterReminderService._();
  WaterReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ID range: 2000–2100 dành riêng cho water reminders
  static const int _baseId = 2000;
  static const int _maxSlots = 100;

  static const _channelId = 'water_reminder';
  static const _channelName = 'Nhắc nhở uống nước';

  Future<void> initialize() async {
    // Khởi tạo timezone database (dùng alias riêng để tránh conflict)
    tzdata.initializeTimeZones();

    // Set múi giờ Việt Nam làm mặc định
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Lên lịch tất cả nhắc nhở theo cài đặt
  Future<void> scheduleReminders({
    required int intervalMinutes,
    required int startHour,
    required int endHour,
  }) async {
    await cancelAllReminders();

    final times = _buildTimesInDay(
      intervalMinutes: intervalMinutes,
      startHour: startHour,
      endHour: endHour,
    );

    final messages = [
      'Uống một ly nước ngay nhé! 💧',
      'Đến giờ uống nước rồi, hãy bổ sung ngay! 💦',
      'Cơ thể cần nước – hãy uống một ly nhé! 🥤',
      'Đừng quên uống nước, sức khỏe là vàng! 💧',
    ];

    for (int i = 0; i < times.length && i < _maxSlots; i++) {
      final (hour, minute) = times[i];
      final msg = messages[i % messages.length];

      await _scheduleDaily(
        id: _baseId + i,
        hour: hour,
        minute: minute,
        title: 'Nhắc nhở uống nước 💧',
        body: msg,
      );
    }
  }

  Future<void> cancelAllReminders() async {
    for (int i = 0; i < _maxSlots; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
  }

  /// Tạo danh sách thời gian trong ngày theo khoảng cách
  List<(int, int)> _buildTimesInDay({
    required int intervalMinutes,
    required int startHour,
    required int endHour,
  }) {
    final times = <(int, int)>[];
    int totalMinutes = startHour * 60;
    final endMinutes = endHour * 60;

    while (totalMinutes <= endMinutes) {
      final h = totalMinutes ~/ 60;
      final m = totalMinutes % 60;
      times.add((h, m));
      totalMinutes += intervalMinutes;
    }
    return times;
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Nếu giờ đã qua thì đặt lịch cho ngày mai
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Nhắc bạn uống nước đều đặn mỗi ngày',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
