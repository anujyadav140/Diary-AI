import 'package:diarify/components/chips.dart';
import 'package:diarify/components/diary_bar.dart';
import 'package:diarify/components/diary_snippet.dart';
import 'package:diarify/components/image.dart';
import 'package:flutter/material.dart';

class FullDiaryEntry extends StatelessWidget {
  const FullDiaryEntry(
      {super.key,
      required this.title,
      required this.time,
      required this.entry,
      required this.tags,
      required this.link});
  final String title;
  final String time;
  final String entry;
  final List<dynamic> tags;
  final String link;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width / 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DiaryBar(
                  expandDiarySnippet: () {},
                  date: 'Title',
                  diaryContent: title,
                  isImage: true,
                  link: link,
                ),
                TagChips(tags: tags),
                Text(entry),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
