import 'package:doctor_care/domain/entities/step_count.dart';

class StepCountModel extends StepCount {
  final int? profileId;

  StepCountModel({
    super.id,
    required super.steps,
    super.distance,
    super.caloriesBurned,
    required super.timestamp,
    super.note,
    this.profileId,
  });

  factory StepCountModel.fromMap(Map<String, dynamic> map) {
    return StepCountModel(
      id: map['id'],
      profileId: map['profileId'],
      steps: map['steps'],
      distance: map['distance'] != null
          ? (map['distance'] as num).toDouble()
          : null,
      caloriesBurned: map['caloriesBurned'] != null
          ? (map['caloriesBurned'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId':profileId,
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
