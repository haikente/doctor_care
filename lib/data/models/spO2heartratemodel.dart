import 'package:doctor_care/domain/entities/spO2heartrate.dart';

class Spo2heartratemodel extends SpO2HeartRate {
  final int? profileId;
  Spo2heartratemodel({
    super.id,
    required super.spo2,
    required super.heartRate,
    required super.timestamp,
    super.note,
    super.source,
    this.profileId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'spo2': spo2,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'source': source.name,
    };
  }

  factory Spo2heartratemodel.fromMap(Map<String, dynamic> map) {
    return Spo2heartratemodel(
      id: map['id'],
      profileId: map['profileId'],
      spo2: map['spo2'],
      heartRate: map['heartRate'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'] as String?,
      source: _parseSource(map['source'] as String?),
    );
  }

  static SpO2Source _parseSource(String? value) {
    if (value == 'healthConnect') return SpO2Source.healthConnect;
    return SpO2Source.manual;
  }
}
