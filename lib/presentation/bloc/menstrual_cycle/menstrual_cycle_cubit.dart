import 'package:doctor_care/domain/entities/menstrual_cycle.dart';
import 'package:doctor_care/domain/usecase/menstrual_cycle/delete_menstrual_cycle.dart';
import 'package:doctor_care/domain/usecase/menstrual_cycle/get_menstrual_cycles.dart';
import 'package:doctor_care/domain/usecase/menstrual_cycle/insert_menstrual_cycle.dart';
import 'package:doctor_care/domain/usecase/menstrual_cycle/update_menstrual_cycle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'menstrual_cycle_state.dart';

class MenstrualCycleCubit extends Cubit<MenstrualCycleState> {
  final GetMenstrualCycles getMenstrualCycles;
  final InsertMenstrualCycle insertMenstrualCycle;
  final UpdateMenstrualCycle updateMenstrualCycle;
  final DeleteMenstrualCycle deleteMenstrualCycle;

  MenstrualCycleCubit({
    required this.getMenstrualCycles,
    required this.insertMenstrualCycle,
    required this.updateMenstrualCycle,
    required this.deleteMenstrualCycle,
  }) : super(MenstrualCycleInitial());

  Future<void> loadCycles() async {
    emit(MenstrualCycleLoading());
    try {
      final cycles = await getMenstrualCycles();
      emit(_buildLoadedState(cycles));
    } catch (e) {
      emit(MenstrualCycleError('Không tải được dữ liệu chu kỳ'));
    }
  }

  Future<void> addCycle(MenstrualCycle cycle) async {
    try {
      await insertMenstrualCycle(cycle);
      final cycles = await getMenstrualCycles();
      emit(_buildLoadedState(cycles));
    } catch (e) {
      emit(MenstrualCycleFailure('Không thể thêm chu kỳ'));
    }
  }

  Future<void> editCycle(MenstrualCycle cycle) async {
    try {
      await updateMenstrualCycle(cycle);
      final cycles = await getMenstrualCycles();
      emit(_buildLoadedState(cycles));
    } catch (e) {
      emit(MenstrualCycleFailure('Không thể cập nhật chu kỳ'));
    }
  }

  Future<void> removeCycle(int id) async {
    try {
      await deleteMenstrualCycle(id);
      final cycles = await getMenstrualCycles();
      emit(_buildLoadedState(cycles));
    } catch (e) {
      emit(MenstrualCycleFailure('Không thể xóa chu kỳ'));
    }
  }

  /// Xây dựng trạng thái loaded với các tính toán dự đoán
  MenstrualCycleLoaded _buildLoadedState(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) {
      return MenstrualCycleLoaded(cycles: cycles);
    }

    // Sắp xếp theo ngày bắt đầu mới nhất
    final sorted = [...cycles]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final currentCycle = sorted.first;

    // Tính trung bình cycleLength từ các chu kỳ có dữ liệu đầy đủ
    final withLength = sorted
        .where((c) => c.cycleLength != null && c.cycleLength! > 0)
        .take(6)
        .toList();

    double? avgCycleLength;
    if (withLength.isNotEmpty) {
      final sum = withLength.fold<int>(0, (s, c) => s + c.cycleLength!);
      avgCycleLength = sum / withLength.length;
    }

    // Nếu không có cycleLength nào, dùng mặc định 28 ngày
    final estimatedCycleLength = avgCycleLength?.round() ?? 28;

    // Dự đoán ngày bắt đầu chu kỳ tiếp theo
    final predictedNextStart = currentCycle.startDate
        .add(Duration(days: estimatedCycleLength));

    // Rụng trứng xảy ra trước kỳ kinh tiếp theo 14 ngày
    final predictedOvulation = predictedNextStart.subtract(const Duration(days: 14));

    // Cửa sổ thụ thai: 5 ngày trước đến 1 ngày sau rụng trứng
    final fertileStart = predictedOvulation.subtract(const Duration(days: 5));
    final fertileEnd = predictedOvulation.add(const Duration(days: 1));

    return MenstrualCycleLoaded(
      cycles: sorted,
      averageCycleLength: avgCycleLength,
      currentCycle: currentCycle,
      predictedNextStart: predictedNextStart,
      predictedOvulation: predictedOvulation,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
    );
  }
}
