import 'package:doctor_care/domain/entities/temperature.dart';

class TemperatureModel extends Temperature {
  final int? profileId;

  TemperatureModel({
    super.id,
    this.profileId,
    required super.value,
    required super.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TemperatureModel.fromMap(Map<String, dynamic> map) {
    return TemperatureModel(
      id: map['id'],
      profileId: map['id'],
      value: map['value'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
