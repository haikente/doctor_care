import 'package:doctor_care/domain/entities/blood_sugar.dart';

class BloodSugarModel extends BloodSugar {
  final int? profileId;
  BloodSugarModel({
    super.id,
    required super.value,
    required super.mealStatus,
    required super.timestamp,
    super.note,
    this.profileId,
  });

  factory BloodSugarModel.fromMap(Map<String, dynamic> map) {
    return BloodSugarModel(
      id: map['id'],
      profileId: map['profileId'],
      value: (map['value'] as num).toDouble(),
      mealStatus: map['mealStatus'] ?? 'random',
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'value': value,
      'mealStatus': mealStatus,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
