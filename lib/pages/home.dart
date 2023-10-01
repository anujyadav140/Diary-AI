import 'dart:io';
import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:diarify_ai/pages/wave.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class DiarifyHome extends StatefulWidget {
  const DiarifyHome({super.key});

  @override
  State<DiarifyHome> createState() => _DiarifyHomeState();
}

class _DiarifyHomeState extends State<DiarifyHome> {
  late final RecorderController recorderController;

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory = Directory('');
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
      backgroundColor: Colors.white,
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
      body: Column(
        children: [
          Center(
              child: isRecording
                  ? Container()
                  : WaveBubble(path: path, appDirectory: appDirectory))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _startOrStopRecording,
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
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
