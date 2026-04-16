import 'package:doctor_care/domain/entities/sleep_record.dart';

class SleepRecordModel extends SleepRecord {
  final int? profileId;
  SleepRecordModel({
    super.id,
    required super.bedTime,
    required super.wakeTime,
    required super.quality,
    required super.timestamp,
    super.note,
    this.profileId,
  });

  factory SleepRecordModel.fromMap(Map<String, dynamic> map) {
    return SleepRecordModel(
      id: map['id'],
      profileId: map['profileId'],
      bedTime: DateTime.parse(map['bedTime']),
      wakeTime: DateTime.parse(map['wakeTime']),
      quality: map['quality'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'profileId': profileId,
    };
  }
}
