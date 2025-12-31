import 'package:doctor_care/domain/entities/temperature.dart';

class TemperatureModel extends Temperature{
  TemperatureModel({
    super.id,
    required super.value, 
    required super.timestamp
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }  

  factory TemperatureModel.fromMap(Map<String, dynamic> map) {
    return TemperatureModel(
      id: map['id'],
      value: map['value'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}