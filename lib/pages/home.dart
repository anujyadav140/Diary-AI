import 'dart:io';
import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:diarify/components/slide_act.dart';
import 'package:diarify/components/audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';

class DiarifyHome extends StatefulWidget {
  const DiarifyHome({super.key});

  @override
  State<DiarifyHome> createState() => _DiarifyHomeState();
}

class _DiarifyHomeState extends State<DiarifyHome> {
  late final RecorderController recorderController;
  AudioPlayer audioPlayer = AudioPlayer();

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  Directory appDirectory = Directory('');
  bool isDeleted = false;
  @override
  void initState() {
    super.initState();
    _getDir();
    _initialiseControllers();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title:
              const Text('Diarify AI', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0.0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {},
            ),
          ]),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(children: [
                Text(
                  'Hi, Ahir!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Record your thoughts ...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: isRecording
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.08),
                          child: DiarifyAudioPlayer(path: path),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  // Handle Continue action
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
                        ),
                      ],
                    ),
            ))
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
              onPressed: _startOrStopRecording,
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
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.black,
        backgroundColor: Colors.white,
        items: const <Widget>[
          Icon(Icons.list, color: Colors.white, size: 30),
          Icon(Icons.add, color: Colors.white, size: 30),
          Icon(Icons.calendar_month, color: Colors.white, size: 30),
        ],
        onTap: (index) {
          //Handle button tap
        },
      ),
    );
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        final path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
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
