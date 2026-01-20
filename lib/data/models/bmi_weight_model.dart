import 'package:doctor_care/domain/entities/bmi_weight.dart';

class BMIWeightModel extends BMIWeight {
  BMIWeightModel({
    super.id,
    required super.weight,
    required super.height,
    required super.timestamp,
    super.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory BMIWeightModel.fromMap(Map<String, dynamic> map) {
    return BMIWeightModel(
      id: map['id'],
      weight: map['weight'],
      height: map['height'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }
}
