import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:flutter/material.dart';

class Examinationschedule extends StatelessWidget {
  const Examinationschedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(title: "Lịch khám", centerTitle: true,),
    );
  }
}