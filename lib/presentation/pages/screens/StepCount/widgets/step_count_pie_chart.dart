import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/domain/entities/step_count.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StepCountPieChart extends StatefulWidget {
  final List<StepCount> records;

  const StepCountPieChart({super.key, required this.records});

  @override
  State<StepCountPieChart> createState() => _StepCountPieChartState();
}

class _StepCountPieChartState extends State<StepCountPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  static const _buckets = <_StepBucket>[
    _StepBucket(
      localizationKey: 'step_status_sedentary',
      color: Color(0xFFE11D48),
      backgroundColor: Color(0xFFFFF1F2),
      icon: Icons.airline_seat_recline_normal,
    ),
    _StepBucket(
      localizationKey: 'step_status_light',
      color: Color(0xFFF97316),
      backgroundColor: Color(0xFFFFF7ED),
      icon: Icons.directions_walk,
    ),
    _StepBucket(
      localizationKey: 'step_status_moderate',
      color: Color(0xFFEAB308),
      backgroundColor: Color(0xFFFEFCE8),
      icon: Icons.directions_walk,
    ),
    _StepBucket(
      localizationKey: 'step_status_good',
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFF0FDF4),
      icon: Icons.directions_run,
    ),
    _StepBucket(
      localizationKey: 'step_status_very_active',
      color: Color(0xFF0891B2),
      backgroundColor: Color(0xFFECFEFF),
      icon: Icons.emoji_events_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bucketCounts = <_StepBucket, int>{};
    for (final record in widget.records) {
      final bucket = _bucketFor(record.steps);
      bucketCounts[bucket] = (bucketCounts[bucket] ?? 0) + 1;
    }

    final totalRecords = widget.records.length;
    final totalSteps = widget.records.fold<int>(
      0,
      (sum, record) => sum + record.steps,
    );
    final averageSteps = (totalSteps / totalRecords).round();

    // Find max count for bar scaling
    final maxCount = bucketCounts.values.fold<int>(0, (a, b) => a > b ? a : b);

    final legendItems = _buckets.map((bucket) {
      final count = bucketCounts[bucket] ?? 0;
      return _LegendItem(
        bucket: bucket,
        count: count,
        percent: totalRecords > 0 ? count / totalRecords * 100 : 0,
      );
    }).toList();

    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.24 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insert_chart_outlined_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('step_activity_distribution'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const Gap(2),
                        Text(
                          context.tr(
                            'record_count',
                            params: {'count': '$totalRecords'},
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MetricBadge(
                    icon: Icons.trending_up,
                    value: _formatNumber(averageSteps),
                    label: context.tr('average'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const Gap(6),

            // ── Stacked distribution bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact stacked bar showing distribution
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: legendItems
                                .where((item) => item.count > 0)
                                .map((item) {
                              return Expanded(
                                flex: item.count,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  decoration: BoxDecoration(
                                    color: item.bucket.color
                                        .withOpacity(_animation.value),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Gap(14),

            // ── Horizontal bar items ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return Column(
                    children: legendItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      // Stagger animation for each bar
                      final staggerDelay = idx * 0.1;
                      final barProgress = Interval(
                        staggerDelay.clamp(0.0, 0.5),
                        (staggerDelay + 0.6).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ).transform(_animation.value);

                      return _BarItem(
                        item: item,
                        label: context.tr(item.bucket.localizationKey),
                        maxCount: maxCount,
                        isDark: isDark,
                        progress: barProgress,
                        hasData: item.count > 0,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StepBucket _bucketFor(int steps) {
    if (steps < 3000) return _buckets[0];
    if (steps < 6000) return _buckets[1];
    if (steps < 10000) return _buckets[2];
    if (steps < 15000) return _buckets[3];
    return _buckets[4];
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      final millions = number / 1000000;
      return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M';
    }
    if (number >= 1000) {
      final thousands = number / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k';
    }
    return number.toString();
  }
}

// ── Metric Badge ──
class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _MetricBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const Gap(5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Horizontal Bar Item ──
class _BarItem extends StatelessWidget {
  final _LegendItem item;
  final String label;
  final int maxCount;
  final bool isDark;
  final double progress;
  final bool hasData;

  const _BarItem({
    required this.item,
    required this.label,
    required this.maxCount,
    required this.isDark,
    required this.progress,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction = maxCount > 0 ? item.count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Icon indicator
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: hasData
                  ? item.bucket.color.withOpacity(0.12)
                  : (isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.bucket.icon,
              size: 15,
              color: hasData
                  ? item.bucket.color
                  : (isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
            ),
          ),
          const Gap(10),
          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: hasData
                            ? (isDark ? Colors.white : const Color(0xFF374151))
                            : (isDark ? Colors.white30 : const Color(0xFFD1D5DB)),
                      ),
                    ),
                    if (hasData)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.count}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF374151),
                            ),
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: item.bucket.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.percent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: item.bucket.color,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                        ),
                      ),
                  ],
                ),
                const Gap(5),
                // Animated horizontal bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxBarWidth = constraints.maxWidth;
                    final barWidth = maxBarWidth * barFraction * progress;

                    return Stack(
                      children: [
                        // Background track
                        Container(
                          height: 6,
                          width: maxBarWidth,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // Filled bar
                        if (hasData)
                          Container(
                            height: 6,
                            width: barWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  item.bucket.color.withOpacity(0.8),
                                  item.bucket.color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: progress > 0.3
                                  ? [
                                      BoxShadow(
                                        color: item.bucket.color
                                            .withOpacity(0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models ──
class _StepBucket {
  final String localizationKey;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const _StepBucket({
    required this.localizationKey,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}

class _LegendItem {
  final _StepBucket bucket;
  final int count;
  final double percent;

  const _LegendItem({
    required this.bucket,
    required this.count,
    required this.percent,
  });
}
