import 'package:flutter/material.dart';

class DiarifyDay extends StatefulWidget {
  const DiarifyDay({super.key});

  @override
  State<DiarifyDay> createState() => _DiarifyDayState();
}

class _DiarifyDayState extends State<DiarifyDay> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Center(
          child: Text(
              'Diary Entries',
              style: TextStyle(color: Colors.white),
            ),
        ));
  }
}
