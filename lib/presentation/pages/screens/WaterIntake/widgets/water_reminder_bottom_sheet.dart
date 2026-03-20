import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/presentation/bloc/water_reminder/water_reminder_cubit.dart';
import 'package:doctor_care/presentation/bloc/water_reminder/water_reminder_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class WaterReminderBottomSheet extends StatelessWidget {
  const WaterReminderBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WaterReminderCubit>(),
        child: const WaterReminderBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: BlocBuilder<WaterReminderCubit, WaterReminderState>(
        builder: (context, state) {
          final cubit = context.read<WaterReminderCubit>();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),

              // ── Tiêu đề + toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhắc nhở uống nước',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        Text(
                          state.isEnabled
                              ? '${state.reminderCount} lần nhắc/ngày'
                              : 'Đang tắt',
                          style: TextStyle(
                            fontSize: 12,
                            color: state.isEnabled
                                ? Colors.blue
                                : AppColor.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: state.isEnabled,
                    activeColor: Colors.blue,
                    onChanged: (_) async {
                      final ok = await cubit.toggle();
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vui lòng cấp quyền thông báo trong cài đặt',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const Gap(20),

              // ── Khoảng cách nhắc nhở
              _SectionLabel(label: 'Khoảng cách nhắc nhở'),
              const Gap(10),
              _IntervalSelector(
                selected: state.intervalMinutes,
                onSelect: cubit.updateInterval,
              ),
              const Gap(20),

              // ── Khung giờ hoạt động
              _SectionLabel(label: 'Khung giờ hoạt động'),
              const Gap(10),
              _TimeRangeRow(
                startHour: state.startHour,
                endHour: state.endHour,
                onStartChanged: (v) =>
                    cubit.updateTimeRange(v, state.endHour),
                onEndChanged: (v) =>
                    cubit.updateTimeRange(state.startHour, v),
              ),
              const Gap(16),

              // ── Banner tóm tắt khi bật
              if (state.isEnabled) _SummaryBanner(state: state),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets nội bộ ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColor.textSecondary(context),
      ),
    );
  }
}

class _IntervalSelector extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;

  const _IntervalSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      (30, '30 phút'),
      (60, '1 giờ'),
      (90, '1.5 giờ'),
      (120, '2 giờ'),
    ];

    return Row(
      children: options.map((opt) {
        final (val, label) = opt;
        final isSelected = selected == val;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(val),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : Colors.blue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  final int startHour;
  final int endHour;
  final void Function(int) onStartChanged;
  final void Function(int) onEndChanged;

  const _TimeRangeRow({
    required this.startHour,
    required this.endHour,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HourPicker(
            label: 'Từ',
            value: startHour,
            min: 5,
            max: 12,
            onChanged: onStartChanged,
          ),
        ),
        const Gap(12),
        const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
        const Gap(12),
        Expanded(
          child: _HourPicker(
            label: 'Đến',
            value: endHour,
            min: 13,
            max: 23,
            onChanged: onEndChanged,
          ),
        ),
      ],
    );
  }
}

class _HourPicker extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _HourPicker({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColor.textSecondary(context),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 20,
                  color: value > min ? Colors.blue : Colors.grey.shade300,
                ),
              ),
              const Gap(8),
              Text(
                '$value:00',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: value < max ? Colors.blue : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final WaterReminderState state;
  const _SummaryBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: Colors.blue, size: 18),
          const Gap(10),
          Expanded(
            child: Text(
              'Nhắc ${state.intervalLabel.toLowerCase()} từ ${state.startHour}:00 đến ${state.endHour}:00 · ${state.reminderCount} lần/ngày',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
