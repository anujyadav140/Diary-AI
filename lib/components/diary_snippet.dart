import 'dart:async';

import 'package:diarify/components/chips.dart';
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
      required this.entryCount});
  final int entryCount;
  final String date;

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
                GestureDetector(
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
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 30.0),
                              child: Text(
                                widget.date,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 22,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.diaryContent,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.025,
                  ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add image here',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 30),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.image),
                      ),
                    ],
                  ),
                ),
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
