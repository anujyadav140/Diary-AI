import 'dart:io';
import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:diarify/components/diary_snippet.dart';
import 'package:diarify/components/idle.dart';
import 'package:diarify/components/slide_act.dart';
import 'package:diarify/components/audio_player.dart';
import 'package:diarify/pages/diarify_generation.dart';
import 'package:diarify/pages/full_diary_entry.dart';
import 'package:diarify/services/authservice.dart';
import 'package:diarify/services/diarify_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiarifyHomeContent extends StatefulWidget {
  const DiarifyHomeContent({super.key});

  @override
  State<DiarifyHomeContent> createState() => _DiarifyHomeContentState();
}

class _DiarifyHomeContentState extends State<DiarifyHomeContent> {
  late final RecorderController recorderController;
  AudioPlayer audioPlayer = AudioPlayer();

  String path = '';
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  Directory appDirectory = Directory('');
  bool isDeleted = false;
  String displayName = '';
  String firstName = '';
  String profilePic = '';
  PageController pageController = PageController();
  int currentPage = 0; // Current page index
  @override
  void initState() {
    // Retrieve the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName!;
      profilePic = user.photoURL!;
      if (displayName.isNotEmpty) {
        // Split the full name by spaces and take the first part
        List<String> nameParts = displayName.split(' ');
        firstName = nameParts[0];
      }
    }
    super.initState();
    _getDir();
    _initialiseControllers();
    DiarifyServices()
        .getDiarifyDatePointer(context)
        .then((date) => loadData(date));
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    recorderController.dispose();
    pageController.dispose(); // Dispose the page controller
    super.dispose();
  }

  DateTime selectedDate = DateTime.now(); // Initialize with the current date
  String title = "";
  DateTime dateTime = DateTime.now();
  List<dynamic> tags = [];
  String link = "";
  String entry = "";
  int count = 0;
  Future<void> loadData(String? date) async {
    try {
      DocumentSnapshot? latestEntry =
          await DiarifyServices().getLatestDiaryEntry(date);

      if (latestEntry != null && latestEntry.exists) {
        // Access the data within the document
        title = latestEntry['title'];
        Timestamp time = latestEntry['time'];
        entry = latestEntry['entry'];
        tags = latestEntry['tags'];
        link = latestEntry['link'];
        count = latestEntry['count'];
        // Convert the Timestamp to a DateTime
        dateTime = time.toDate();
        setState(() {});
        // formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
        // Now you can use the retrieved data as needed
        print('Title: $title');
        print('Time: $dateTime');
        print('Entry: $entry');
        print('Emotion Tags: $tags');
        print('image link: $link');
      } else {
        print('No latest diary entry found.');
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.075,
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(children: [
                Text(
                  'Record your thoughts ...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            !context.read<AuthService>().isMicActive
                ? DiarifySnippet(
                    date:
                        "${DateFormat('dd/MM').format(dateTime)}\n${DateFormat('HH:mm').format(dateTime)}\n${DateFormat('EEE').format(dateTime)}",
                    diaryContent: title,
                    expandDiarySnippet: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return FullDiaryEntry(
                            title: title,
                            entry: entry,
                            time: DateFormat('E MMM d y').format(dateTime),
                            tags: tags,
                            link: link,
                          );
                        },
                      ));
                    },
                    tags: tags,
                    entryCount: count,
                    link: link,
                  )
                : Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.08),
                            child: !isRecording && isRecordingCompleted
                                ? DiarifyAudioPlayer(
                                    path: path,
                                    display:
                                        !isRecording && isRecordingCompleted,
                                  )
                                : Column(
                                    children: [
                                      AnimatedTextKit(
                                        isRepeatingAnimation: true,
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                              'Describe your day, thoughts, feelings and so on ...',
                                              textStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          25)),
                                          TypewriterAnimatedText('Listening...',
                                              textStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          25)),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1),
                                        child: Lottie.asset(
                                          'assets/mic_loading.json',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.10),
                            child: !isRecording && isRecordingCompleted
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: _startOrStopRecording,
                                            child: const Column(
                                              children: [
                                                Text(
                                                  'Restart',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .black, // Change the color as needed
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_back,
                                                  size: 30,
                                                  color: Colors
                                                      .black, // Change the color as needed
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  20), // Add some spacing between the GestureDetector widgets
                                          GestureDetector(
                                            onTap: () {
                                              context
                                                  .read<AuthService>()
                                                  .imageDone = false;
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return DiarifyGeneration(
                                                    path: path,
                                                  );
                                                },
                                              ));
                                            },
                                            child: const Column(
                                              children: [
                                                Text(
                                                  'Continue',
                                                  style: TextStyle(
                                                    color: Colors
                                                        .black, // Change the color as needed
                                                  ),
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward, // You may need to replace with the actual icon you want to use
                                                  size: 30,
                                                  color: Colors
                                                      .black, // Change the color as needed
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            context
                                                .read<AuthService>()
                                                .isMicActive = false;
                                          });
                                        },
                                        child: const Column(
                                          children: [
                                            Text(
                                              'Go Home',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Change the color as needed
                                              ),
                                            ),
                                            Icon(
                                              Icons
                                                  .arrow_downward, // You may need to replace with the actual icon you want to use
                                              size: 30,
                                              color: Colors
                                                  .black, // Change the color as needed
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isRecording
                ? AudioWaveforms(
                    enableGesture: true,
                    size: Size(MediaQuery.of(context).size.width * 0.6, 50),
                    recorderController: recorderController,
                    waveStyle: const WaveStyle(
                        waveColor: Colors.white,
                        extendWaveform: true,
                        showMiddleLine: false,
                        backgroundColor: Colors.black),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.only(left: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  )
                : const SizedBox(
                    width: 1,
                    height: 1,
                  ),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                setState(() {
                  context.read<AuthService>().isMicActive = true;
                });
                _startOrStopRecording();
              },
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        final path = await recorderController.stop(false);

        if (path != null) {
          setState(() {
            isRecordingCompleted = true;
          });
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path).lengthSync()}");

          setState(() {
            this.path = path;
          });
        }
      } else {
        // If not recording, start a new recording
        await recorderController.record(path: path!);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }
}
