import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/temperature.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/Temperature/insert_temperature.dart';
import 'package:doctor_care/presentation/pages/screens/Temperature/widgets/filter_bottom_sheet_Temperature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {

  String selectedStatus = ""; 
  DateTime? startDate; 
  DateTime? endDate; 

  @override
  void initState() {
    super.initState();
    context.read<TemperatureCubit>().loadTemperatureRecords();
  }

    // Lọc dữ liệu theo trạng thái và thời gian (cho danh sách card)
  List<Temperature> filterByStatus(List<Temperature> records) {
    List<Temperature> filtered = records;

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
      filtered = filtered.where((record) => record.getStatus == selectedStatus).toList();
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
        onBack:() => Navigator.pop(context),
         title: "Theo dõi nhiệt độ",
         centerTitle: true,
         icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 20,),
         onInfo: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => InsertTemperature(),));
      },
     ), 
     body: BlocBuilder<TemperatureCubit, TemperatureState>(
      builder: (context, state) {
        if (state is TemperatureLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue[600],
            ));
        } else if (state is TemperatureLoaded) {
          final temperature = state.temperatures;

          if (temperature.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined, size: 80, color: Colors.grey),
                  Gap(20),
                  Text(
                    'Chưa có dữ liệu nhiệt độ',
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

           final filteredRecords = filterByStatus(temperature); 

          return SingleChildScrollView(
            child: Column(
              children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${filteredRecords.length} bản ghi", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        GestureDetector(
                          onTap: () {
                            AppDialog.showCustomBottomSheet(
                              context: context,
                              child: FilterbottomsheetTemperature(
                                initialStartDate: startDate,
                                initialEndDate: endDate,
                                initialStatus: selectedStatus,
                                firstAvailableDate: temperature.first.timestamp,
                                lastAvailableDate: temperature.last.timestamp,
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
                          child: Icon(Icons.filter_list, color: Colors.black54,),
                        )
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Chip ngày - luôn hiển thị khoảng thời gian hiện tại
                          if (startDate != null && endDate != null)
                          Container(
                           padding: EdgeInsets.all(5),
                           decoration: BoxDecoration(
                           color: Colors.blue[50],
                           borderRadius: BorderRadius.circular(6),
                           border: Border.all(color: Colors.blue.shade900, width: 1.5),
                           ),
                           child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${formatDate(startDate!)} - ${formatDate(endDate!)}",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.blue.shade900),                     
                              ),
                              Gap(6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    startDate = null;
                                    endDate = null;
                                  });
                                },
                                child: Icon(Icons.clear, size: 14, color: Colors.blue.shade900,))
                            ],
                           ),
                          ),
                          
                          // Chip trạng thái - hiện khi có chọn trạng thái cụ thể
                          if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả")
                          Container(
                           padding: EdgeInsets.all(5),
                           decoration: BoxDecoration(
                           color: Colors.blue[50],
                           borderRadius: BorderRadius.circular(6),
                           border: Border.all(color: Colors.blue.shade900, width: 1.5),
                           ),
                           child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedStatus,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.blue.shade900),                     
                              ),
                              Gap(6),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedStatus = ""; // Reset filter trạng thái
                                  });
                                },
                                child: Icon(Icons.clear, size: 14, color: Colors.blue.shade900,))
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
                                foregroundColor: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // List view
                  if (filteredRecords.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true, //dùng trong column
                    physics: const NeverScrollableScrollPhysics(), // không cuộn riêng
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final data = filteredRecords[filteredRecords.length - 1 - index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 13),  // Giống với margin của card
                        child: Slidable(
                          key: ValueKey(data.id),
                          endActionPane: ActionPane(
                            motion: StretchMotion(),
                            extentRatio: 0.25,
                            children: [
                              CustomSlidableAction(
                                onPressed: (_) {
                                  AppDialog.showDeleteConfirm(
                                    context: context,
                                    onConfirm: () {
                                      // Xóa bản ghi từ database
                                      if (data.id != null) {
                                      context.read<TemperatureCubit>().deleteTemperatureRecord(data.id.toString());
                                    }
                                    // Hiển thị snackbar
                                    AppSnackBar.show(
                                      context: context,
                                      type: SnackBarType.delete,
                                    );
                                  }
                                );
                              },
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                padding: EdgeInsets.zero,
                                autoClose: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_forever_outlined, color: Colors.white, size: 20),
                                    Gap(2),
                                    Text('Xóa',style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => InsertTemperature(temperature: data),
                              ));
                            },
                          child: _buildDataCard(data),
                          ),
                        ),
                      );
                    },
                  ),


              ],
            ),
          );
        } else if (state is TemperatureError) {
          return Center(child: Text(state.message));
        } else {
          return Center(child: Text("Không có dữ liệu"));
        }
      },
        ),
      );
  }

  Widget _buildDataCard(Temperature temperature) {
    return Container(
      constraints: BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.blue.shade500,   // đoạn màu xanh
        Colors.blue.shade300,   // giữ nguyên xanh đến điểm stops
        Colors.white,  // phần còn lại màu trắng
        Colors.white,
      ],
      stops: [
        0.0,  // bắt đầu
        0.2,  // xanh hết 0%
        0.3,  // từ đây chuyển sang trắng
        1.0,  // hết container
      ]
      ),
    color: Colors.white10,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.blue.shade200, width: 1.5),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            children: [
              Text('${temperature.value}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
              Gap(5),
              Text('°C', style: TextStyle(color: Colors.black, fontSize: 24),),
            ],
          ),

          Row(
            children: [
              Text('${temperature.timestamp.day.toString().padLeft(2,"0")}/${temperature.timestamp.month}/${temperature.timestamp.year}',
                style: TextStyle(color: Colors.grey.shade600,  fontSize: 12),),
              Gap(5),
              Text('${temperature.timestamp.hour}:${temperature.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey.shade600,  fontSize: 12))
                ],
              ),
            ],
          ),

          Spacer(),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
            color: temperature.getBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: temperature.getColor)
          ),
            child: Text(temperature.getStatus.toString(),
            style: TextStyle(fontSize: 11, color: temperature.getColor, fontWeight: FontWeight.bold),)
          )
        ],
      ),
    ),
    );
  }
}