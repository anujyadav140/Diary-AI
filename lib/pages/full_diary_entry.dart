import 'package:flutter/material.dart';

class FullDiaryEntry extends StatelessWidget {
  const FullDiaryEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: Center(
        child: Text('Diary Entry'),
      ),
    ));
  }
}
