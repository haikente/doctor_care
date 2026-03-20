import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/presentation/bloc/health_goal/health_goal_cubit.dart';
import 'package:doctor_care/presentation/bloc/health_goal/health_goal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HealthGoalScreen extends StatelessWidget {
  const HealthGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomStackAppBar(
        title: 'Mục tiêu sức khỏe',
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: BlocBuilder<HealthGoalCubit, HealthGoalState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  'Hoạt động hàng ngày',
                  Icons.directions_run_rounded,
                  Colors.blue,
                ),
                const Gap(12),
                _buildGoalCard(
                  context,
                  title: 'Số bước chân',
                  subtitle: 'Mục tiêu bước chân mỗi ngày',
                  value: '${state.dailySteps}',
                  unit: 'bước',
                  icon: Icons.directions_walk_rounded,
                  iconColor: Colors.green,
                  bgColor: Colors.green.shade50,
                  onEdit: () => _showEditDialog(
                    context,
                    title: 'Mục tiêu bước chân',
                    unit: 'bước',
                    initialValue: state.dailySteps.toString(),
                    isDecimal: false,
                    min: 1000,
                    max: 50000,
                    onSave: (v) => context
                        .read<HealthGoalCubit>()
                        .updateDailySteps(v.toInt()),
                  ),
                ),
                const Gap(12),
                _buildGoalCard(
                  context,
                  title: 'Lượng nước uống',
                  subtitle: 'Mục tiêu uống nước mỗi ngày',
                  value: '${state.dailyWaterMl}',
                  unit: 'ml',
                  icon: Icons.water_drop_rounded,
                  iconColor: Colors.blue,
                  bgColor: Colors.blue.shade50,
                  onEdit: () => _showEditDialog(
                    context,
                    title: 'Mục tiêu uống nước',
                    unit: 'ml',
                    initialValue: state.dailyWaterMl.toString(),
                    isDecimal: false,
                    min: 500,
                    max: 5000,
                    onSave: (v) => context
                        .read<HealthGoalCubit>()
                        .updateDailyWater(v.toInt()),
                  ),
                ),
                const Gap(12),
                _buildGoalCard(
                  context,
                  title: 'Lượng calo nạp vào',
                  subtitle: 'Mục tiêu calo mỗi ngày',
                  value: '${state.dailyCalories}',
                  unit: 'kcal',
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: Colors.orange,
                  bgColor: Colors.orange.shade50,
                  onEdit: () => _showEditDialog(
                    context,
                    title: 'Mục tiêu calo',
                    unit: 'kcal',
                    initialValue: state.dailyCalories.toString(),
                    isDecimal: false,
                    min: 1000,
                    max: 5000,
                    onSave: (v) => context
                        .read<HealthGoalCubit>()
                        .updateDailyCalories(v.toInt()),
                  ),
                ),
                const Gap(24),
                _buildSectionHeader(
                  context,
                  'Giấc ngủ & Cân nặng',
                  Icons.bedtime_rounded,
                  Colors.purple,
                ),
                const Gap(12),
                _buildGoalCard(
                  context,
                  title: 'Thời gian ngủ',
                  subtitle: 'Mục tiêu số giờ ngủ mỗi đêm',
                  value: state.sleepHours.toStringAsFixed(1),
                  unit: 'giờ',
                  icon: Icons.bedtime_rounded,
                  iconColor: Colors.purple,
                  bgColor: Colors.purple.shade50,
                  onEdit: () => _showEditDialog(
                    context,
                    title: 'Mục tiêu giấc ngủ',
                    unit: 'giờ',
                    initialValue: state.sleepHours.toString(),
                    isDecimal: true,
                    min: 4,
                    max: 12,
                    onSave: (v) =>
                        context.read<HealthGoalCubit>().updateSleepHours(v),
                  ),
                ),
                const Gap(12),
                _buildGoalCard(
                  context,
                  title: 'Cân nặng mục tiêu',
                  subtitle: state.targetWeight == 0
                      ? 'Chưa đặt mục tiêu'
                      : 'Mục tiêu cân nặng của bạn',
                  value: state.targetWeight == 0
                      ? '--'
                      : state.targetWeight.toStringAsFixed(1),
                  unit: 'kg',
                  icon: Icons.monitor_weight_rounded,
                  iconColor: Colors.teal,
                  bgColor: Colors.teal.shade50,
                  onEdit: () => _showEditDialog(
                    context,
                    title: 'Cân nặng mục tiêu',
                    unit: 'kg',
                    initialValue: state.targetWeight == 0
                        ? '65'
                        : state.targetWeight.toString(),
                    isDecimal: true,
                    min: 30,
                    max: 200,
                    onSave: (v) =>
                        context.read<HealthGoalCubit>().updateTargetWeight(v),
                  ),
                ),
                const Gap(32),
                _buildResetButton(context),
                const Gap(20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const Gap(10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? iconColor.withOpacity(0.15)
                  : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary(context),
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const Gap(4),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 12, color: iconColor),
                      const Gap(4),
                      Text(
                        'Sửa',
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showResetConfirmDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restart_alt_rounded,
              color: Colors.red.shade400,
              size: 20,
            ),
            const Gap(8),
            Text(
              'Đặt lại về mặc định',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String unit,
    required String initialValue,
    required bool isDecimal,
    required num min,
    required num max,
    required Function(double) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập giá trị ($min – $max $unit)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const Gap(12),
                  TextField(
                    controller: controller,
                    keyboardType: isDecimal
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.number,
                    inputFormatters: [
                      if (isDecimal)
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'),
                        )
                      else
                        FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      suffixText: unit,
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Huỷ',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text);
                    if (parsed == null) {
                      setDialogState(() => errorText = 'Giá trị không hợp lệ');
                      return;
                    }
                    if (parsed < min || parsed > max) {
                      setDialogState(() => errorText = 'Phải từ $min đến $max');
                      return;
                    }
                    onSave(parsed);
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    final cubit = context.read<HealthGoalCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đặt lại mục tiêu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tất cả mục tiêu sẽ được đặt lại về giá trị mặc định. Bạn có chắc không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Huỷ', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.updateDailySteps(10000);
              cubit.updateDailyWater(2000);
              cubit.updateDailyCalories(2000);
              cubit.updateSleepHours(8.0);
              cubit.updateTargetWeight(0);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
  }
}
