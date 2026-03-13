import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/core/pages/custom_date_range_picker.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FilterbottomsheetTemperature extends StatefulWidget {
  final DateTime? initialStartDate; 
  final DateTime? initialEndDate;
  final String initialStatus; 
  final DateTime firstAvailableDate;
  final DateTime lastAvailableDate; 
  final Function(DateTime?, DateTime?, String) onApply; 
  final VoidCallback onReset;

  const FilterbottomsheetTemperature({
    super.key, 
    this.initialStartDate, 
    this.initialEndDate, 
    required this.initialStatus, 
    required this.firstAvailableDate, 
    required this.lastAvailableDate, 
    required this.onApply, 
    required this.onReset
  });

  @override
  State<FilterbottomsheetTemperature> createState() => _FilterbottomsheetTemperatureState();
}

class _FilterbottomsheetTemperatureState extends State<FilterbottomsheetTemperature> {
  late DateTime? tempStartDate;
  late DateTime? tempEndDate;
  late String tempStatus; 
  late String tempClassify; 

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempEndDate = widget.initialEndDate;
    tempStatus = widget.initialStatus;
    tempClassify = ""; 
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
           "${date.month.toString().padLeft(2, '0')}/"
           "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== HEADER ==========
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 16, left: 16),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      context.tr('filter_results'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.clear, size: 24),
                )
              ],
            ),
          ),
          Divider(),

          // ========== THá»œI GIAN ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(context.tr('time'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Gap(4),
                Icon(Icons.grade, color: Colors.red, size: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCustomDatePicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tempStartDate != null && tempEndDate != null
                          ? "${formatDate(tempStartDate!)} - ${formatDate(tempEndDate!)}"
                          : "${formatDate(widget.firstAvailableDate)} - ${formatDate(widget.lastAvailableDate)}",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ========== Phân loại ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.tr('classification'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "";
                      });
                    },
                    child: _buildClassifyChip(context.tr('all'), tempClassify == ""),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "Nhập tay";
                      });
                    },
                    child: _buildClassifyChip(context.tr('manual_entry'), tempClassify == "Nhập tay"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempClassify = "Thiết bị";
                      });
                    },
                    child: _buildClassifyChip(context.tr('device'), tempClassify == "Thiết bị"),
                  ),
                ),
              ],
            ),
          ),

          // ========== TRáº NG THÃI (dÃ¹ng tempStatus) ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.tr('status'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = ""; 
                      });
                    },
                    child: _buildStatusChip(context.tr('all'), tempStatus == ""),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Hạ nhiệt";
                      });
                    },
                    child: _buildStatusChip(context.tr('temp_low'), tempStatus == "Hạ nhiệt"),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Bình thường";
                      });
                    },
                    child: _buildStatusChip(context.tr('status_normal'), tempStatus == "Bình thường"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Sốt nhẹ";
                      });
                    },
                    child: _buildStatusChip(context.tr('temp_mild_fever'), tempStatus == "Sốt nhẹ"),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Sốt vừa";
                      });
                    },
                    child: _buildStatusChip(context.tr('temp_moderate_fever'), tempStatus == "Sốt vừa"),
                  ),
                ),
                Gap(8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        tempStatus = "Sốt cao";
                      });
                    },
                    child: _buildStatusChip(context.tr('temp_high_fever'), tempStatus == "Sốt cao"),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                
                Expanded(
                  child: CustomButton(
                    text: context.tr('filter'),
                    onPressed: () {
                      setState(() {
                        tempStartDate = widget.firstAvailableDate;
                        tempEndDate = widget.lastAvailableDate;
                        tempStatus = "";
                        tempClassify = "";
                      });
                    
                      widget.onReset();
                    },
                    gradient: [Colors.blue.shade50, Colors.blue.shade50],
                    textColor: Colors.blue,
                  ),
                ),
                Gap(10),
               
                Expanded(
                  child: CustomButton(
                    text: context.tr('apply'),
                    onPressed: () {
                      if (tempStartDate != null && tempEndDate != null) {
                        if (tempStartDate!.isAfter(tempEndDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('date_range_invalid')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      // âœ… Apply filter
                      widget.onApply(
                        tempStartDate ?? widget.firstAvailableDate,
                        tempEndDate ?? widget.lastAvailableDate,
                        tempStatus,
                      );
                      Navigator.pop(context);
                    },
                    gradient: [Colors.blue.shade600, Colors.blue.shade900],
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CUSTOM DATE PICKER ==========
  void _openCustomDatePicker(BuildContext context) {
    CustomDateRangePickerDialog.show(
      context: context,
      initialStartDate: tempStartDate,
      initialEndDate: tempEndDate,
      onConfirm: (start, end) {
        setState(() {
          tempStartDate = start;
          tempEndDate = end;
        });
      },
    );
  }
  // ========== BUILD CHIPS ==========
  Widget _buildClassifyChip(String label, bool isSelected) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }
}