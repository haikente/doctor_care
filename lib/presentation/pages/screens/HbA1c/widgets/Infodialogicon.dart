import 'package:doctor_care/core/ui/dialog_helper.dart';
import 'package:flutter/material.dart';

class InfoDialogIcon extends StatelessWidget {
  final Image image;
  final InlineSpan content;

  const InfoDialogIcon({
    super.key,
    required this.image,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: GestureDetector(
        onTap: () {
          AppDialog.showInformation(
            context: context,
            images: image,
            content: RichText(
              textAlign: TextAlign.center,
              text: content,
            ),
          );
        },
        child: const Icon(
          Icons.info_outline,
          size: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
