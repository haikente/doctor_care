part of 'menstrual_cycle_cubit.dart';

abstract class MenstrualCycleState {}

class MenstrualCycleInitial extends MenstrualCycleState {}

class MenstrualCycleLoading extends MenstrualCycleState {}

class MenstrualCycleLoaded extends MenstrualCycleState {
  final List<MenstrualCycle> cycles;

  /// Trung bình độ dài chu kỳ (từ 3 chu kỳ gần nhất có cycleLength)
  final double? averageCycleLength;

  /// Chu kỳ hiện tại (đang diễn ra hoặc gần nhất)
  final MenstrualCycle? currentCycle;

  /// Ngày dự kiến bắt đầu chu kỳ tiếp theo
  final DateTime? predictedNextStart;

  /// Ngày rụng trứng dự kiến
  final DateTime? predictedOvulation;

  /// Ngày bắt đầu cửa sổ thụ thai (5 ngày trước rụng trứng)
  final DateTime? fertileWindowStart;

  /// Ngày kết thúc cửa sổ thụ thai (1 ngày sau rụng trứng)
  final DateTime? fertileWindowEnd;

  MenstrualCycleLoaded({
    required this.cycles,
    this.averageCycleLength,
    this.currentCycle,
    this.predictedNextStart,
    this.predictedOvulation,
    this.fertileWindowStart,
    this.fertileWindowEnd,
  });
}

class MenstrualCycleError extends MenstrualCycleState {
  final String message;
  MenstrualCycleError(this.message);
}

class MenstrualCycleFailure extends MenstrualCycleState {
  final String message;
  MenstrualCycleFailure(this.message);
}
