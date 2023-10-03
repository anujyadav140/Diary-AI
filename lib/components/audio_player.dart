import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DiarifyAudioPlayer extends StatefulWidget {
  const DiarifyAudioPlayer({super.key, this.path, required this.display});
  final bool display;
  final String? path;

  @override
  State<DiarifyAudioPlayer> createState() => _DiarifyAudioPlayerState();
}

class _DiarifyAudioPlayerState extends State<DiarifyAudioPlayer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      // When audio playback completes, seek to the start
      audioPlayer.seek(Duration.zero);
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
    super.initState();
  }

  Future setAudio() async {
    await audioPlayer.play(DeviceFileSource(widget.path!));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.display
        ? Column(
            children: [
              SizedBox(
                child: Slider(
                  activeColor: Colors.black,
                  inactiveColor: Colors.black54,
                  thumbColor: Colors.black,
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble().clamp(
                      0, duration.inSeconds.toDouble()), // Clamp the value
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    audioPlayer.seek(position);
                  },
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(formatTime(position)),
                Text(formatTime(duration - position)),
              ]),
              CircleAvatar(
                backgroundColor: Colors.black,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      audioPlayer.pause();
                    } else {
                      audioPlayer.play(DeviceFileSource(widget.path!));
                    }
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                ),
              )
            ],
          )
        : Container();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}
