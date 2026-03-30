import 'package:doctor_care/domain/entities/creatinine.dart';

class CreatinineModel extends Creatinine {
  final int? profileId;

  CreatinineModel({
    super.id,
    required super.value,
    required super.timestamp,
    super.note,
    super.age,
    super.gender,
    this.profileId,
  });

  factory CreatinineModel.fromMap(Map<String, dynamic> map) {
    return CreatinineModel(
      id: map['id'],
      profileId: map['profileId'],
      value: (map['value'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
      age: map['age'],
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'age': age,
      'gender': gender,
      'profileId': profileId,
    };
  }
}
