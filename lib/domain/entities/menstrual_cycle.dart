class MenstrualCycle {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength; // Số ngày từ đầu chu kỳ này đến đầu chu kỳ tiếp theo
  final int periodLength; // Số ngày hành kinh thực tế
  final List<String> symptoms; // Danh sách triệu chứng
  final String? note;

  MenstrualCycle({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength = 5,
    this.symptoms = const [],
    this.note,
  });

  /// Số ngày hành kinh thực tế (tính từ startDate đến endDate)
  int get actualPeriodLength {
    if (endDate == null) return periodLength;
    return endDate!.difference(startDate).inDays + 1;
  }

  /// Chu kỳ đang diễn ra (chưa có endDate)
  bool get isOngoing => endDate == null;

  /// Ngày dự kiến kết thúc hành kinh (nếu chưa có endDate)
  DateTime get expectedEndDate =>
      startDate.add(Duration(days: periodLength - 1));

  MenstrualCycle copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    List<String>? symptoms,
    String? note,
    int? profileId,
  }) {
    return MenstrualCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
    );
  }
}
