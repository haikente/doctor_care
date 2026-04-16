import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/health_metrics_grid.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/health_status_card.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/home_header.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/step_count_target_chart.dart';
import 'package:doctor_care/presentation/pages/mainscreen/widgets/today_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    _loadAllHealthData();
  }

  // hàm load dữ liệu sức khỏe từ các cubit/bloc khi trang được khởi tạo
  void _loadAllHealthData() {
    context.read<BloodPressureCubit>().loadBloodPressureRecords();

    context.read<Hba1cCubit>().loadHba1cRecords();

    context.read<TemperatureCubit>().loadTemperatureRecords();

    context.read<Spo2heartrateBloc>().add(LoadSpo2HeartRateRecords());

    context.read<StepCountCubit>().loadStepCounts();

    context.read<SleepRecordCubit>().loadSleepRecords();

    context.read<WaterIntakeBloc>().add(LoadWaterIntakeRecords());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const HomeHeader(),
            const Gap(24),
            const HealthStatusCard(),
            const Gap(24),
            const StepCountTargetChart(),
            const Gap(24),
            const HealthMetricsGrid(),
            const Gap(24),
            const TodayTarget(),
            const Gap(100),
          ],
        ),
      ),
    );
  }
}
