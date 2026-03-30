import 'package:doctor_care/domain/entities/water_intake.dart';

class WaterIntakeModel extends WaterIntake {
  WaterIntakeModel({
    super.id,
    required super.amount,
    required super.timestamp,
    super.note,
    super.profileId,
  });

  // From Map (SQLite)
  factory WaterIntakeModel.fromMap(Map<String, dynamic> map) {
    return WaterIntakeModel(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      note: map['note'] as String?,
      profileId: map['profileId'] as int?,
    );
  }

  // To Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'profileId': profileId,
    };
  }

  // CopyWith
  WaterIntakeModel copyWith({
    int? id,
    int? amount,
    DateTime? timestamp,
    String? note,
    int? profileId,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      profileId: profileId ?? this.profileId,
    );
  }
}
