import 'package:doctor_care/domain/entities/spO2heartrate.dart';

class Spo2heartratemodel extends SpO2HeartRate{
  Spo2heartratemodel({
    super.id,
    required super.spo2, 
    required super.heartRate,
    required super.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spo2': spo2,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Spo2heartratemodel.fromMap(Map<String, dynamic> map) {
    return Spo2heartratemodel(
      id: map['id'],
      spo2: map['spo2'],
      heartRate: map['heartRate'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}