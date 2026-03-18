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
        final recordDate = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
        final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return (recordDate.isAtSameMomentAs(start) || recordDate.isAfter(start)) &&
               (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }
    
    // Lọc theo trạng thái (chỉ khi có chọn trạng thái cụ thể)
    if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả") {
      filtered = filtered.where((record) => record.combinedStatus == selectedStatus).toList();
    } 

    return filtered;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
           "${date.month.toString().padLeft(2, '0')}/"
           "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "SPO2 & Nhịp tim",
        centerTitle: true,
        icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 20),
        onInfo: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => InsertSpo2HeartRate()),
          );
        },
      ), 
      body: BlocConsumer<Spo2heartrateBloc, Spo2heartrateState>(
        listener: (context, state) {
          // Reload data khi quay lại từ insert/edit screen
          if (state is Spo2heartrateLoaded) {
            // Data refreshed
          }
        },
        builder: (context, state) {
          if (state is Spo2heartrateLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.purple[600],
              ),
            );
          } else if (state is Spo2heartrateLoaded) {
            final records = state.records;

            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline, size: 80, color: Colors.grey),
                    Gap(20),
                    Text(
                      'Chưa có dữ liệu SPO2 & Nhịp tim',
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Gap(10),
                    Text(
                      'Nhấn nút + để thêm bản ghi mới',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final filteredRecords = filterByStatus(records); 

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${filteredRecords.length} bản ghi", 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                          child: Icon(Icons.science_outlined, color: Colors.black54),
                        )
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
                          // Chip ngày
                          if (startDate != null && endDate != null)
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.purple.shade900, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${formatDate(startDate!)} - ${formatDate(endDate!)}",
                                  style: TextStyle(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w500, 
                                    letterSpacing: 0.5, 
                                    color: Colors.purple.shade900
                                  ),                     
                                ),
                                Gap(6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      startDate = null;
                                      endDate = null;
                                    });
                                  },
                                  child: Icon(Icons.clear, size: 14, color: Colors.purple.shade900),
                                )
                              ],
                            ),
                          ),
                          
                          // Chip trạng thái
                          if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả")
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.purple.shade900, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedStatus,
                                  style: TextStyle(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w500, 
                                    letterSpacing: 0.5, 
                                    color: Colors.purple.shade900
                                  ),                     
                                ),
                                Gap(6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedStatus = "";
                                    });
                                  },
                                  child: Icon(Icons.clear, size: 14, color: Colors.purple.shade900),
                                )
                              ],
                            ),
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
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                            Gap(16),
                            Text(
                              'Không tìm thấy kết quả',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(8),
                            Text(
                              'Thử thay đổi bộ lọc của bạn',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Gap(20),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  startDate = null;
                                  endDate = null;
                                  selectedStatus = "";
                                });
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Xóa bộ lọc'),
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
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Slidable(
                            key: ValueKey(record.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    final bloc = context.read<Spo2heartrateBloc>();
                                    AppDialog.showDeleteConfirm(
                                      context: context,
                                      onConfirm: () {
                                        if(!mounted) return;

                                        final id = record.id;
                                        if(id != null ){
                                        bloc.add(DeleteSpo2HeartRateRecord(id.toString()));
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
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
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
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  Gap(16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Gap(8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecordCard(SpO2HeartRate record) {
    final statusColor = record.combinedColor;
    final statusIcon = record.spo2Icon; // Dùng icon SPO2 làm icon chính
    
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    Gap(6),
                    Text(
                      formatDate(record.timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      Gap(4),
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
            
            Gap(12),
            
            // SPO2 & Heart Rate values
            Row(
              children: [
                // SPO2
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
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
                            Icon(Icons.water_drop, size: 16, color: Colors.blue[700]),
                            Gap(4),
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
                        Gap(6),
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
                
                Gap(12),
                
                // Heart Rate
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
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
                            Icon(Icons.favorite, size: 16, color: Colors.red[700]),
                            Gap(4),
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
                        Gap(6),
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
                            Gap(4),
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
