import 'dart:convert';
import 'package:doctor_care/domain/entities/menstrual_cycle.dart';

class MenstrualCycleModel extends MenstrualCycle {
  final int? profileId;
  MenstrualCycleModel({
    super.id,
    required super.startDate,
    super.endDate,
    super.cycleLength,
    super.periodLength,
    super.symptoms,
    super.note,
    this.profileId,
  });

  factory MenstrualCycleModel.fromMap(Map<String, dynamic> map) {
    List<String> symptomsList = [];
    if (map['symptoms'] != null &&
        map['symptoms'] is String &&
        (map['symptoms'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(map['symptoms'] as String);
        if (decoded is List) {
          symptomsList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return MenstrualCycleModel(
      id: map['id'],
      profileId: map['profileId'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'])
          : null,
      cycleLength: map['cycleLength'],
      periodLength: map['periodLength'] ?? 5,
      symptoms: symptomsList,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'profileId': profileId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'symptoms': jsonEncode(symptoms),
      'note': note,
    };
  }

  static MenstrualCycleModel fromEntity(MenstrualCycle e, {int? profileId}) {
    return MenstrualCycleModel(
      id: e.id,
      startDate: e.startDate,
      endDate: e.endDate,
      cycleLength: e.cycleLength,
      periodLength: e.periodLength,
      symptoms: e.symptoms,
      note: e.note,
      profileId: profileId,
    );
  }
}
