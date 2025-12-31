import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:doctor_care/core/ui/snackbar_helper.dart';
import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/pages/healthmonitoring/hba1c_chart.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/insert_hba1c.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

class Hba1cScreen extends StatefulWidget {
  const Hba1cScreen({super.key});

  @override
  State<Hba1cScreen> createState() => _Hba1cScreenState();
}

class _Hba1cScreenState extends State<Hba1cScreen> {
  // Filter cho danh sách card
  String selectedStatus = ""; // Trạng thái được chọn
  DateTime? startDate; // Ngày bắt đầu
  DateTime? endDate; // Ngày kết thúc
  
  // Filter cho chart
  String chartSelectedStatus = ""; 
  DateTime? chartStartDate;
  DateTime? chartEndDate;
  
  @override
  void initState() {
    super.initState();
    // Load dữ liệu HbA1c khi màn hình khởi tạo
    context.read<Hba1cCubit>().loadHba1cRecords();
  }
  // Lọc dữ liệu theo trạng thái và thời gian (cho danh sách card)
  List<HbA1c> filterByStatus(List<HbA1c> records) {
    List<HbA1c> filtered = records;
    
    // Lọc theo thời gian
    if (startDate != null && endDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return (recordDate.isAtSameMomentAs(start) || recordDate.isAfter(start)) &&
               (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }
    // Lọc theo trạng thái (chỉ khi có chọn trạng thái cụ thể)
    if (selectedStatus.isNotEmpty && selectedStatus != "Tất cả") {
      if (selectedStatus == "Cao") {
        // "Cao" bao gồm cả "Tiền đái tháo đường" và "Đái tháo đường"
        filtered = filtered.where((record) => 
          record.getInterpretation == "Tiền đái tháo đường" || 
          record.getInterpretation == "Đái tháo đường"
        ).toList();
      } else {
        filtered = filtered.where((record) => record.getInterpretation == selectedStatus).toList();
      }
    }
    return filtered;
  }
  // Lọc dữ liệu cho chart
  List<HbA1c> filterChartData(List<HbA1c> records) {
    List<HbA1c> filtered = records;
    
    // Lọc theo thời gian
    if (chartStartDate != null && chartEndDate != null) {
      filtered = filtered.where((record) {
        final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
        final start = DateTime(chartStartDate!.year, chartStartDate!.month, chartStartDate!.day);
        final end = DateTime(chartEndDate!.year, chartEndDate!.month, chartEndDate!.day);
        return (recordDate.isAtSameMomentAs(start) || recordDate.isAfter(start)) &&
               (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }
    
    // Lọc theo trạng thái
    if (chartSelectedStatus.isNotEmpty && chartSelectedStatus != "Tất cả") {
      if (chartSelectedStatus == "Cao") {
        filtered = filtered.where((record) => 
          record.getInterpretation == "Tiền đái tháo đường" || 
          record.getInterpretation == "Đái tháo đường"
        ).toList();
      } else {
        filtered = filtered.where((record) => record.getInterpretation == chartSelectedStatus).toList();
      }
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
         title: "Theo dõi HbA1c",
         centerTitle: true,
         icon: const Icon(Icons.add_circle_outline_outlined, color: Colors.white, size: 20,),
         onInfo: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => InsertHba1c(),));
      },
     ), 

    body: BlocBuilder<Hba1cCubit, Hba1cState>(
      builder: (context, state) {
        if (state is Hba1cLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue[600],
            ));
        } else if (state is Hba1cLoaded) {
          final hba1cRecords = state.hba1cRecords;

          if (hba1cRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined, size: 80, color: Colors.grey),
                  Gap(20),
                  Text(
                    'Chưa có dữ liệu HbA1c',
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

      
          if (hba1cRecords.isNotEmpty && (startDate == null || endDate == null)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                // Set cho card filter
                startDate = hba1cRecords.first.date;
                endDate = hba1cRecords.last.date;
                // Set cho chart filter
                chartStartDate = hba1cRecords.first.date;
                chartEndDate = hba1cRecords.last.date;
              });
            });
          }
        
          final filteredRecords = filterByStatus(hba1cRecords); // Dữ liệu đã lọc cho card
          final chartFilteredData = filterChartData(hba1cRecords); // Dữ liệu đã lọc cho chart
          
          // Kiểm tra nếu list rỗng
          return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 415,
                      child: Hba1cChart(
                        data: chartFilteredData, // Sử dụng dữ liệu đã lọc cho chart
                        onFilterTap: () {
                          // Mở filter bottom sheet cho chart
                          AppDialog.showCustomBottomSheet(
                            context: context,
                            child: FilterBottomSheet(
                              initialStartDate: chartStartDate,
                              initialEndDate: chartEndDate,
                              initialStatus: chartSelectedStatus,
                              firstAvailableDate: hba1cRecords.first.date,
                              lastAvailableDate: hba1cRecords.last.date,
                              onApply: (newStartDate, newEndDate, newStatus) {
                                setState(() {
                                  chartStartDate = newStartDate;
                                  chartEndDate = newEndDate;
                                  chartSelectedStatus = newStatus;
                                });
                              },
                              onReset: () {
                                setState(() {
                                  chartStartDate = hba1cRecords.first.date;
                                  chartEndDate = hba1cRecords.last.date;
                                  chartSelectedStatus = "";
                                });
                              },
                            ),
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                          );
                        },
                      ),
                    ),
                  ),
                  
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${filteredRecords.length} bản ghi", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        GestureDetector(
                          onTap: () {
                            // Filter cho danh sách card bản ghi
                            AppDialog.showCustomBottomSheet(
                              context: context,
                              child: FilterBottomSheet(
                                initialStartDate: startDate,
                                initialEndDate: endDate,
                                initialStatus: selectedStatus,
                                firstAvailableDate: hba1cRecords.first.date,
                                lastAvailableDate: hba1cRecords.last.date,
                                onApply: (newStartDate, newEndDate, newStatus) {
                                  setState(() {
                                    startDate = newStartDate;
                                    endDate = newEndDate;
                                    selectedStatus = newStatus;
                                  });
                                },
                                onReset: () {
                                  setState(() {
                                    startDate = hba1cRecords.first.date;
                                    endDate = hba1cRecords.last.date;
                                    selectedStatus = "";
                                  });
                                },
                              ),
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: true,
                            );
                          },
                          child: Icon(Icons.science_outlined, color: Colors.black54,),
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
                                onTap: (){
                                  setState(() {
                                    // Reset về khoảng thời gian mặc định
                                    startDate = hba1cRecords.first.date;
                                    endDate = hba1cRecords.last.date;
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
                  //card bản ghi
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
                                      context.read<Hba1cCubit>().deleteHba1cRecord(data.id.toString());
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
                                builder: (context) => InsertHba1c(hba1c: data),
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
        } else if (state is Hba1cError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('Không có dữ liệu HbA1c'));
        }
      },
    ),
  );
}

Widget _buildDataCard(HbA1c hbA1c){
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
              Text('${hbA1c.value}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
              Gap(5),
              Text('%', style: TextStyle(color: Colors.black, fontSize: 24),),
            ],
          ),

          Row(
            children: [
              Text('${hbA1c.date.day.toString().padLeft(2,"0")}/${hbA1c.date.month}/${hbA1c.date.year}',
                style: TextStyle(color: Colors.grey.shade600,  fontSize: 12),),
              Gap(5),  
              Text('${hbA1c.date.hour}:${hbA1c.date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey.shade600,  fontSize: 12))
                ],
              ),
            ],
          ),

          Spacer(),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
            color: hbA1c.getBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hbA1c.getColor)
          ),
            child: Text(hbA1c.getInterpretation.toString(), 
            style: TextStyle(fontSize: 11, color: hbA1c.getColor, fontWeight: FontWeight.bold),)
          )
        ],
      ),
    ),
    );
  }
}
