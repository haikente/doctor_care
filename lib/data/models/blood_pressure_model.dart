import 'package:doctor_care/domain/entities/blood_pressure.dart';

class BloodPressureModel extends BloodPressure{
  BloodPressureModel({
    super.id,
    required super.timestamp, 
    required super.systolic, 
    required super.diastolic});

    factory BloodPressureModel.fromMap(Map<String, dynamic> map) {
    return BloodPressureModel(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      systolic: map['systolic'],
      diastolic: map['diastolic'],
    );
    }

    Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
    };
    }
}