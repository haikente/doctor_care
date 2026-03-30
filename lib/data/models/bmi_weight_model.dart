import 'package:doctor_care/domain/entities/bmi_weight.dart';

class BMIWeightModel extends BMIWeight {
  final int? profileId;
  BMIWeightModel({
    super.id,
    required super.weight,
    required super.height,
    required super.timestamp,
    this.profileId,
    super.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'weight': weight,
      'height': height,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory BMIWeightModel.fromMap(Map<String, dynamic> map) {
    return BMIWeightModel(
      id: map['id'],
      profileId: map['profileId'],
      weight: map['weight'],
      height: map['height'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }
}
