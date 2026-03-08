import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:flutter/material.dart';

class InsertDish extends StatelessWidget {
  const InsertDish({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Thêm mới món ăn",
        centerTitle: true,
      ),
    );
  }
}