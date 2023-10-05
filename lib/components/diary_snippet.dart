import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DiarifySnippet extends StatefulWidget {
  const DiarifySnippet(
      {super.key,
      required this.date,
      required this.time,
      required this.diaryContent});
  final String date;
  final String time;
  final String diaryContent;

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
        DateFormat('hh:mm a').format(now); // Format the time as desired
    return formattedTime;
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formattedDate =
        DateFormat('dd/MM/yyyy').format(now); // Example format: "yyyy-MM-dd"
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
  }

  List<String> tags = ['Funny', 'Sad', 'Eclectic', 'Anecdotal'];
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
              "${getCurrentDate()} - ${getCurrentTime()}",
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
                      "Diary Entry #121:",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: Colors.black),
                    ),
                  ),
                ),
                Container(
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
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 30.0),
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
                              fontSize: MediaQuery.of(context).size.width / 30),
                        ),
                      ),
                    ],
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(tags.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Chip(
                          elevation: 0.8,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          label: Text(
                            tags[index],
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                color: Colors.white),
                          ),
                          backgroundColor: Colors.black,
                          shadowColor: Colors.black,
                        ),
                      );
                    }),
                  ),
                ),
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
