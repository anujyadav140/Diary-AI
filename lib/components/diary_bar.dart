import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DiaryBar extends StatefulWidget {
  const DiaryBar(
      {super.key,
      required this.expandDiarySnippet,
      required this.date,
      required this.diaryContent});
  final VoidCallback expandDiarySnippet;
  final String date;
  final String diaryContent;
  @override
  State<DiaryBar> createState() => _DiaryBarState();
}

class _DiaryBarState extends State<DiaryBar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: widget.expandDiarySnippet,
      onTap: widget.expandDiarySnippet,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 30.0),
                  child: Text(
                    widget.date,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 22,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                widget.diaryContent,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
