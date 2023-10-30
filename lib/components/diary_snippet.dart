import 'dart:async';

import 'package:diarify/components/chips.dart';
import 'package:diarify/components/diary_bar.dart';
import 'package:diarify/components/image.dart';
import 'package:diarify/services/diarify_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiarifySnippet extends StatefulWidget {
  const DiarifySnippet(
      {super.key,
      required this.date,
      required this.diaryContent,
      required this.expandDiarySnippet,
      required this.tags,
      required this.entryCount,
      required this.link});
  final int entryCount;
  final String date;
  final String link;
  final String diaryContent;
  final List<dynamic> tags;
  final VoidCallback expandDiarySnippet;

  @override
  State<DiarifySnippet> createState() => _DiarifySnippetState();
}

class _DiarifySnippetState extends State<DiarifySnippet> {
  late StateMachineController? _riveController;
  bool isClick = false;
  SMIInput<bool>? isRiveClicked;
  bool isRiveAnimationPlaying = false;

  String getCurrentTime() {
    final now = DateTime.now();
    final formattedTime =
        DateFormat('HH:mm').format(now); // Format the time as desired
    return formattedTime;
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate =
        DateFormat('dd/MM/yyyy').format(now); // Example format: "yyyy-MM-dd"
    return formattedDate;
  }

  String currentTime = "";
  @override
  void initState() {
    currentTime = getCurrentTime(); // Initialize with the current time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = getCurrentTime();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Text(
              "${getCurrentDate()} - $currentTime", // Use the updated time
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 20,
              ),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Diary Entry #${widget.entryCount}:",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: Colors.black),
                    ),
                  ),
                ),
                DiaryBar(
                    expandDiarySnippet: widget.expandDiarySnippet,
                    date: widget.date,
                    diaryContent: widget.diaryContent)
              ],
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Tags:",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: Colors.black),
                    ),
                  ),
                ),
                widget.tags.isEmpty
                    ? const CircularProgressIndicator()
                    : TagChips(tags: widget.tags),
              ],
            ),
            Row(
              children: [
                DiarifyImage(link: widget.link),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Align items in the center vertically
                    children: [
                      isRiveAnimationPlaying
                          ? AnimatedTextKit(
                              isRepeatingAnimation: true,
                              animatedTexts: [
                                TypewriterAnimatedText('Thank you!',
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25)),
                                TypewriterAnimatedText('Helping you!',
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25)),
                              ],
                            )
                          : Container(),
                      !isRiveAnimationPlaying
                          ? AnimatedTextKit(
                              isRepeatingAnimation: true,
                              animatedTexts: [
                                TypewriterAnimatedText('Click on me!',
                                    textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25)),
                                TypewriterAnimatedText('Talk to me!',
                                    textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25)),
                              ],
                            )
                          : Container(),
                      Container(
                        width: 150,
                        height: 150,
                        margin: const EdgeInsets.only(
                            top: 5), // Adjust the top margin as needed
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isClick = !isClick;
                              isRiveAnimationPlaying = !isRiveAnimationPlaying;
                            });
                            isRiveClicked?.change(isClick);
                          },
                          child: RiveAnimation.asset(
                            'assets/hedgehog.riv',
                            fit: BoxFit.cover,
                            stateMachines: const ['State Machine 1'],
                            onInit: (artboard) {
                              _riveController =
                                  StateMachineController.fromArtboard(
                                      artboard, "State Machine 1");
                              if (_riveController == null) return;
                              artboard.addController(_riveController!);
                              isRiveClicked =
                                  _riveController?.findInput<bool>("Walk");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
