import 'dart:convert';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiarifyGeneration extends StatefulWidget {
  const DiarifyGeneration({super.key, required this.path});
  final String path;
  @override
  State<DiarifyGeneration> createState() => _DiarifyGenerationState();
}

class _DiarifyGenerationState extends State<DiarifyGeneration> {
  final openAI = OpenAI.instance.build(
      token: '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',
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  Future<String> convertSpeechToText(String path) async {
    const apiKey = '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';
    var url = Uri.https("api.openai.com", "/v1/audio/transcriptions");
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
    request.fields["model"] = "whisper-1";
    request.fields["language"] = "en";
    request.files.add(await http.MultipartFile.fromPath('file', widget.path));
    var response = await request.send();
    var newResponse = await http.Response.fromStream(response);
    final responseData = json.decode(newResponse.body);
    print(responseData['text']);
    return responseData['text'];
  }

  List<String> emotionTags = [];
  // String transcript =
  // "today was uhh really fun and cool, i did a lot of work today, coded from morning till day, day started off good to be honest but later on i became kind of restless but anyways i am fine, feeling okay, tomorrow i have a job interview not really feeling anything about it ...";
  String generatedResponse = '';

  final StreamController<String> _sseResponseController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    // convertSpeechToText(widget.path)
    //     .then((value) => chatCompleteWithSSE(value));
    super.initState();
  }

  @override
  void dispose() {
    _sseResponseController.close();
    super.dispose();
  }

  void chatCompleteWithSSE(String transcribed) {
    //"expand on it"
    //"be factual"
    print(transcribed.length);
    final request = ChatCompleteText(
      messages: [
        Messages(
            role: Role.assistant,
            content:
                '''you have to rewrite this transcription as journal entry, be factual, remember to use simple, ordinary language,
      this is the transcription: "$transcribed". you also have to give tags to it based on the emotions; return the tags as a list. For example return it as: "Tags: [anxious, sad, lonely]"'''),
        Messages(role: Role.user, content: transcribed),
      ],
      model: GptTurboChatModel(),
      temperature: 0.9,
      stream: true,
      maxToken: 300,
    );

    openAI.onChatCompletionSSE(request: request).listen((it) {
      final response = it.choices?.last.message?.content;

      generatedResponse += '$response'; // Add a newline for each response
      _sseResponseController.sink.add(generatedResponse);
    }).onDone(() {
      extractEmotionTags(generatedResponse);
    });
  }

  void extractEmotionTags(String text) {
    final tagRegExp = RegExp(r'\[(.*?)\]');
    final matches = tagRegExp.allMatches(text);

    if (matches.isNotEmpty) {
      setState(() {
        emotionTags = matches.map((match) => match.group(1)!).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Diary Generation'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(
                  "AI Generated Text:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<String>(
                  stream: _sseResponseController.stream,
                  builder: (context, snapshot) {
                    return Text(snapshot.hasData ? snapshot.data! : '');
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Emotion Tags:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(emotionTags.isEmpty
                    ? 'No tags found'
                    : emotionTags.join(', ')),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Save To Diary'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
