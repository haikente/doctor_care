import 'package:doctor_care/domain/entities/blood_pressure.dart';

class BloodPressureModel extends BloodPressure {
  final int? profileId;

  BloodPressureModel({
    super.id,
    this.profileId,
    required super.timestamp,
    required super.systolic,
    required super.diastolic,
    super.source,
  });

  factory BloodPressureModel.fromMap(Map<String, dynamic> map) {
    return BloodPressureModel(
      id: map['id'],
      profileId: map['profileId'],
      timestamp: DateTime.parse(map['timestamp']),
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      source: map['source'] as String? ?? 'manual',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'source': source,
      'profileId': profileId,
    };
  }
}
