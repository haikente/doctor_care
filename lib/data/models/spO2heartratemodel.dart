import 'package:doctor_care/domain/entities/spO2heartrate.dart';

class Spo2heartratemodel extends SpO2HeartRate {
  final int? profileId;
  Spo2heartratemodel({
    super.id,
    required super.spo2,
    required super.heartRate,
    required super.timestamp,
    this.profileId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'spo2': spo2,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Spo2heartratemodel.fromMap(Map<String, dynamic> map) {
    return Spo2heartratemodel(
      id: map['id'],
      profileId: map['profileId'],
      spo2: map['spo2'],
      heartRate: map['heartRate'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
