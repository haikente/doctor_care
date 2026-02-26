import 'package:doctor_care/domain/entities/blood_sugar.dart';

class BloodSugarModel extends BloodSugar {
  BloodSugarModel({
    super.id,
    required super.value,
    required super.mealStatus,
    required super.timestamp,
    super.note,
  });

  factory BloodSugarModel.fromMap(Map<String, dynamic> map) {
    return BloodSugarModel(
      id: map['id'],
      value: (map['value'] as num).toDouble(),
      mealStatus: map['mealStatus'] ?? 'random',
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'mealStatus': mealStatus,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
