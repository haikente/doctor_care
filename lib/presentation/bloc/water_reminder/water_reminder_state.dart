import 'package:equatable/equatable.dart';

class WaterReminderState extends Equatable {
  final bool isEnabled;
  final int intervalMinutes; // 30 | 60 | 90 | 120
  final int startHour;       // 6–12
  final int endHour;         // 17–23

  const WaterReminderState({
    this.isEnabled = false,
    this.intervalMinutes = 60,
    this.startHour = 7,
    this.endHour = 21,
  });

  WaterReminderState copyWith({
    bool? isEnabled,
    int? intervalMinutes,
    int? startHour,
    int? endHour,
  }) {
    return WaterReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  String get intervalLabel {
    switch (intervalMinutes) {
      case 30:
        return 'Mỗi 30 phút';
      case 60:
        return 'Mỗi 1 giờ';
      case 90:
        return 'Mỗi 1,5 giờ';
      case 120:
        return 'Mỗi 2 giờ';
      default:
        return 'Mỗi $intervalMinutes phút';
    }
  }

  String get timeRangeLabel => '$startHour:00 – $endHour:00';

  int get reminderCount {
    final totalMinutes = (endHour - startHour) * 60;
    return (totalMinutes ~/ intervalMinutes) + 1;
  }

  @override
  List<Object> get props => [isEnabled, intervalMinutes, startHour, endHour];
}
