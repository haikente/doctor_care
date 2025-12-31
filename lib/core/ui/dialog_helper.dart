import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppDialog {
  static Future<void> showDeleteConfirm({
    required BuildContext context,
    required VoidCallback onConfirm,
    String title = 'Xoá bản ghi',
    String content = 'Bạn có chắc chắn muốn xóa bản ghi này?',
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Image.asset(
                Images.bin, width: 60, height: 60),  
              Gap(25),
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
          actions: [
            Row(
              children: [
                Gap(5),
                Expanded(
                  child: CustomButton(
                  text: "Huỷ", 
                  onPressed: () => Navigator.pop(dialogContext),
                  gradient: [Colors.white38, Colors.white38],
                  textColor: Colors.blue,
                  borderColor: Colors.blue,
                  ),
                ),
                Gap(14),
                Expanded(
                  child: CustomButton(
                  text: "Đồng ý", 
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(dialogContext);
                  },
                  gradient: [Colors.blue.shade400, Colors.blue.shade900],
                  textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

   static Future<void> showInformation({
    required BuildContext context,
    String title = 'Thông tin',
    required Widget content,
    String confirmText = 'Đã hiểu',
    VoidCallback? onConfirm,
    Image? images,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (images != null) images,
              Gap(18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: content,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (onConfirm != null) {
                        onConfirm();
                      }
                    },
                    gradient: [Colors.blue.shade300, Colors.blue.shade900],
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<void> showCustomBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    ShapeBorder? shape,
    BorderRadiusGeometry? borderRadius,
    Color? backgroundColor, 
    bool isDismissible = true,    
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return child; // Sử dụng child parameter thay vì hardcode UI
      },
    );
  }
}