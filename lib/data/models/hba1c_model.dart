import 'package:doctor_care/domain/entities/hba1c.dart';

class Hba1cModel extends HbA1c {
  Hba1cModel({
    super.id,
    required super.value,
    required super.date,
  });

  factory Hba1cModel.fromMap(Map<String, dynamic> map) {
    return Hba1cModel(
      id: map['id'],
      value: map['value'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'date': date.toIso8601String(),
    };
  }

 
}
