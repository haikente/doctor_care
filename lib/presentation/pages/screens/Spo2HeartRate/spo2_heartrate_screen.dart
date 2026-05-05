import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/spO2heartrate.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/Spo2HeartRate/insert_spo2_heartrate.dart';
import 'package:doctor_care/presentation/pages/screens/Spo2HeartRate/widgets/filter_bottom_sheet_spo2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class Spo2HeartRateScreen extends StatefulWidget {
  const Spo2HeartRateScreen({super.key});

  @override
  State<Spo2HeartRateScreen> createState() => _Spo2HeartRateScreenState();
}

class _Spo2HeartRateScreenState extends State<Spo2HeartRateScreen> {
  String selectedStatus = "";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    context.read<Spo2heartrateBloc>().add(LoadSpo2HeartRateRecords());
  }

  // Lọc dữ liệu theo trạng thái và thời gian
  List<SpO2HeartRate> filterByStatus(List<SpO2HeartRate> records) {
    List<SpO2HeartRate> filtered = records;

    // Lọc theo thời gian
    if (startDate != null && endDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(
          record.timestamp.year,
          record.timestamp.month,
          record.timestamp.day,
        );
        final start = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return (recordDate.isAtSameMomentAs(start) ||
                recordDate.isAfter(start)) &&
            (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }

    // Lọc theo trạng thái (chỉ khi có chọn trạng thái cụ thể)
    if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả") {
      filtered = filtered
          .where((record) => record.combinedStatus == selectedStatus)
          .toList();
    }

    return filtered;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void _showSyncBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            Icon(Icons.watch, size: 48, color: Colors.blue[600]),
            const Gap(12),
            const Text(
              'Đồng bộ Health Connect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Text(
              'Lấy dữ liệu SpO2 & Nhịp tim từ thiết bị đeo qua Health Connect',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Gap(20),
            _buildSyncOption(ctx, 'Hôm nay', 1, Icons.today),
            const Gap(10),
            _buildSyncOption(ctx, '7 ngày qua', 7, Icons.date_range),
            const Gap(10),
            _buildSyncOption(ctx, '30 ngày qua', 30, Icons.calendar_month),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOption(
    BuildContext ctx,
    String label,
    int days,
    IconData icon,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(ctx);
          context.read<Spo2heartrateBloc>().add(
            SyncFromHealthConnect(daysBack: days),
          );
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue[700],
          side: BorderSide(color: Colors.blue[300]!),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "SPO2 & Nhịp tim",
        centerTitle: true,
        icon: const Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.white,
          size: 20,
        ),
        onInfo: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InsertSpo2HeartRate()),
          );
        },
      ),
      body: BlocConsumer<Spo2heartrateBloc, Spo2heartrateState>(
        listener: (context, state) {
          if (state is Spo2heartrateSyncResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      state.syncedCount > 0 ? Icons.check_circle : Icons.info,
                      color: Colors.white,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: state.syncedCount > 0
                    ? Colors.blue
                    : Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is Spo2heartrateLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue[600]),
            );
          } else if (state is Spo2heartrateSyncing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue[600]),
                  const Gap(20),
                  Text(
                    'Đang đồng bộ từ Health Connect...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Vui lòng chờ trong giây lát',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          } else if (state is Spo2heartrateLoaded) {
            final records = state.records;

            if (records.isEmpty) {
              return _buildEmptyState();
            }

            final filteredRecords = filterByStatus(records);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Sync banner
                  _buildSyncBanner(),

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${filteredRecords.length} bản ghi",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppDialog.showCustomBottomSheet(
                              context: context,
                              child: FilterBottomSheetSpo2(
                                initialStartDate: startDate,
                                initialEndDate: endDate,
                                initialStatus: selectedStatus,
                                firstAvailableDate: records.first.timestamp,
                                lastAvailableDate: records.last.timestamp,
                                onApply: (newStartDate, newEndDate, newStatus) {
                                  setState(() {
                                    startDate = newStartDate;
                                    endDate = newEndDate;
                                    selectedStatus = newStatus;
                                  });
                                },
                                onReset: () {
                                  setState(() {
                                    startDate = null;
                                    endDate = null;
                                    selectedStatus = "";
                                  });
                                },
                              ),
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: true,
                            );
                          },
                          child: Icon(
                            Icons.science_outlined,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (startDate != null && endDate != null)
                            _buildFilterChip(
                              "${formatDate(startDate!)} - ${formatDate(endDate!)}",
                              () => setState(() {
                                startDate = null;
                                endDate = null;
                              }),
                            ),
                          if (selectedStatus.isNotEmpty &&
                              selectedStatus != "Tất cả")
                            _buildFilterChip(
                              selectedStatus,
                              () => setState(() {
                                selectedStatus = "";
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Empty state khi filter không có kết quả
                  if (filteredRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const Gap(16),
                            Text(
                              'Không tìm thấy kết quả',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Thử thay đổi bộ lọc của bạn',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Gap(20),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  startDate = null;
                                  endDate = null;
                                  selectedStatus = "";
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Xóa bộ lọc'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // List of records
                  if (filteredRecords.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Slidable(
                            key: ValueKey(record.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    final bloc = context
                                        .read<Spo2heartrateBloc>();
                                    AppDialog.showDeleteConfirm(
                                      context: context,
                                      onConfirm: () {
                                        if (!mounted) return;
                                        final id = record.id;
                                        if (id != null) {
                                          bloc.add(
                                            DeleteSpo2HeartRateRecord(
                                              id.toString(),
                                            ),
                                          );
                                        }
                                        AppSnackBar.showSpo2heartRate(
                                          context: context,
                                          type: SnackBarType.delete,
                                        );
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Xóa',
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                            child: _buildRecordCard(record),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          } else if (state is Spo2heartrateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const Gap(16),
                  const Text(
                    'Đã xảy ra lỗi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSyncBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.watch, color: Colors.blue[700], size: 24),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Connect',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const Gap(2),
                Text(
                  'Đồng bộ SpO2 & nhịp tim từ thiết bị đeo',
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
          const Gap(8),
          ElevatedButton.icon(
            onPressed: _showSyncBottomSheet,
            icon: const Icon(Icons.sync, size: 16),
            label: const Text('Đồng bộ', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_outline, size: 80, color: Colors.grey),
          const Gap(20),
          const Text(
            'Chưa có dữ liệu SPO2 & Nhịp tim',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(10),
          const Text(
            'Nhấn nút + để nhập tay hoặc đồng bộ từ thiết bị',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Gap(24),
          OutlinedButton.icon(
            onPressed: _showSyncBottomSheet,
            icon: const Icon(Icons.watch, size: 18),
            label: const Text('Đồng bộ từ Health Connect'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.shade900, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Colors.purple.shade900,
            ),
          ),
          const Gap(6),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.clear, size: 14, color: Colors.purple.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(SpO2HeartRate record) {
    final statusColor = record.combinedColor;
    final statusIcon = record.spo2Icon;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsertSpo2HeartRate(record: record),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date, Source Badge & Status
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const Gap(6),
                  Text(
                    formatDate(record.timestamp),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Gap(8),
                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: record.sourceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: record.sourceColor.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          record.sourceIcon,
                          size: 10,
                          color: record.sourceColor,
                        ),
                        const Gap(3),
                        Text(
                          record.sourceLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: record.sourceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const Gap(4),
                        Text(
                          record.combinedStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(12),

              // SPO2 & Heart Rate values
              Row(
                children: [
                  // SPO2
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const Gap(4),
                              Text(
                                'SPO2',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          Text(
                            '${record.spo2}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(12),

                  // Heart Rate
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red[700],
                              ),
                              const Gap(4),
                              Text(
                                'Nhịp tim',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          Row(
                            children: [
                              Text(
                                '${record.heartRate}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'bpm',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
