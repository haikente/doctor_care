import 'package:doctor_care/domain/entities/cholesterol.dart';

class CholesterolModel extends Cholesterol {
  final int? profileId;

  CholesterolModel({
    super.id,
    required super.totalCholesterol,
    required super.hdl,
    required super.ldl,
    required super.triglycerides,
    required super.timestamp,
    super.note,
    this.profileId,
  });

  factory CholesterolModel.fromMap(Map<String, dynamic> map) {
    return CholesterolModel(
      id: map['id'],
      profileId: map['profileId'],
      totalCholesterol: (map['totalCholesterol'] as num).toDouble(),
      hdl: (map['hdl'] as num).toDouble(),
      ldl: (map['ldl'] as num).toDouble(),
      triglycerides: (map['triglycerides'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalCholesterol': totalCholesterol,
      'profileId': profileId,
      'hdl': hdl,
      'ldl': ldl,
      'triglycerides': triglycerides,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
