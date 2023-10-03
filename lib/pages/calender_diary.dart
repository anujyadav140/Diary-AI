import 'package:flutter/material.dart';

class DiarifyCalender extends StatefulWidget {
  const DiarifyCalender({super.key});

  @override
  State<DiarifyCalender> createState() => _DiarifyCalenderState();
}

class _DiarifyCalenderState extends State<DiarifyCalender> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Center(
      child: Text(
        'Calender Diary Entries',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }
}
