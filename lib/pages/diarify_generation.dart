import 'dart:convert';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:diarify/components/chips.dart';
import 'package:diarify/pages/home.dart';
import 'package:diarify/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiarifyGeneration extends StatefulWidget {
  const DiarifyGeneration({super.key, required this.path});
  final String path;
  @override
  State<DiarifyGeneration> createState() => _DiarifyGenerationState();
}

class _DiarifyGenerationState extends State<DiarifyGeneration> {
  final openAI = OpenAI.instance.build(
      token: '',
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  Future<String> convertSpeechToText(String path) async {
    const apiKey = '';
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
  String titleText = '';
  String entryText = '';
  // String transcript =
  // "today was uhh really fun and cool, i did a lot of work today, coded from morning till day, day started off good to be honest but later on i became kind of restless but anyways i am fine, feeling okay, tomorrow i have a job interview not really feeling anything about it ...";
  String generatedResponse = '';

  final StreamController<String> _sseResponseController =
      StreamController<String>.broadcast();

  Future<void> saveDiaryEntry(
      String title, List<String> emotionTags, String entry, int count) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        final date = DateTime.now();
        final time = Timestamp.fromDate(date);

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        // Format the date using DateFormat
        final dateFormat = DateFormat("dd-MM-yyyy");
        final dateFormatted = dateFormat.format(date);

        final documentReference = collectionReference.doc(dateFormatted);

        // Create a subcollection for each entry
        final entryCollection = documentReference.collection("entries");

        // Format the time into a human-readable format
        final timeFormat = DateFormat("h:mm a");
        final timeFormatted = timeFormat.format(date);

        // Use the formatted time as the document ID
        final entryDocument = entryCollection.doc(timeFormatted);

        await entryDocument.set({
          'count': count,
          'title': title,
          'time': time,
          'entry': entry,
          'tags': emotionTags,
        });

        print('Diary entry saved successfully.');
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error saving diary entry: $e');
    }
  }

  bool displaySave = false;
  @override
  void initState() {
    convertSpeechToText(widget.path)
        .then((value) => generateDiaryEntry(value))
        .then((value) => displaySave = true);
    super.initState();
  }

  @override
  void dispose() {
    _sseResponseController.close();
    super.dispose();
  }

  int countWords(String text) {
    // Define a regular expression pattern to match words
    final RegExp wordPattern = RegExp(r'\b\w+\b');

    // Use the allMatches method to find all matches in the text
    final matches = wordPattern.allMatches(text);

    // Return the count of matches, which represents the number of words
    return matches.length;
  }

  void generateDiaryEntry(String transcribed) {
    String wordCount = context.read<AuthService>().settings.selectedWordLimit;
    String style = context.read<AuthService>().settings.selectedStyle;
    String tone = context.read<AuthService>().settings.selectedTry;
    String emotionTags = '';
    String inspirationalQuotes = '';
    String instructions = '';
    int wordsCount = countWords(transcribed);
    int requiredWordCount = wordsCount * 2;

    if (context.read<AuthService>().settings.selectedEmotionTags == "Yes") {
      emotionTags =
          'Give tags to it based on the emotions; return the tags as a list. For example return it as: "Tags: anxious, sad, lonely". Remember that the title will be first and then tags.';
    } else {
      emotionTags = '';
    }
    if (context.read<AuthService>().settings.selectedInspirationalQuotes ==
        "Yes") {
      inspirationalQuotes =
          'Give an inspirational quote that suits the diary entry.';
    } else {
      inspirationalQuotes = '';
    }
    if (context.read<AuthService>().settings.additionalDirections.isNotEmpty) {
      instructions =
          'This is the additional instruction, please follow it: $instructions';
    } else {
      instructions = '';
    }
    //"expand on it"
    //"be factual"
    print(transcribed.length);
    final request = ChatCompleteText(
      messages: [
        Messages(
            role: Role.assistant,
            content:
                '''you have to rewrite this transcription as journal entry, $tone, 
                remember to use simple, ordinary language, and the writing,
                style should be $style,this is the transcription: "$transcribed".
                do not be wordy, be concise, and use $requiredWordCount words,
                just write what is present in the transcription,  
                totally avoid "Dear Diary" and alternatives of it. 
                Give an accurate title to the diary entry as: "Title: ". 
                $emotionTags.
                $inspirationalQuotes. $instructions.
                always write the diary entry, do not just write the title and tag, add content too.'''),
        Messages(role: Role.user, content: transcribed),
      ],
      model: GptTurboChatModel(),
      temperature: 0.9,
      stream: true,
      maxToken: 500,
    );

    openAI.onChatCompletionSSE(request: request).listen((it) {
      final response = it.choices?.last.message?.content;

      generatedResponse += '$response'; // Add a newline for each response
      _sseResponseController.sink.add(generatedResponse);
    }).onDone(() {
      extractTitleTagsAndEntry(generatedResponse);
    });
  }

  void extractTitleTagsAndEntry(String text) {
    // Extract Title
    final titleRegExp = RegExp(r'Title: (.*?)\n');
    final titleMatch = titleRegExp.firstMatch(text);
    final title = titleMatch?.group(1) ?? '';

    // Extract Emotion Tags
    final tagRegExp = RegExp(r'Tags: (.*?)\n');
    final tagMatch = tagRegExp.firstMatch(text);
    final tags = tagMatch?.group(1)?.split(', ').toList() ?? [];

    // Extract Entry
    final entryRegExp = RegExp(r'Tags: (.*?)\n([\s\S]*)');
    final entryMatch = entryRegExp.firstMatch(text);
    final entry = entryMatch?.group(2) ?? '';
    print(entry);
    setState(() {
      emotionTags = tags;
      titleText = title;
      entryText = entry; // Optionally update the generatedResponse
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Diary Generation'),
        // ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Title:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                titleText.isEmpty ? Text('...') : Text(titleText),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Tags:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                emotionTags.isEmpty ? Text('...') : TagChips(tags: emotionTags),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Entry:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder<String>(
                  stream: _sseResponseController.stream,
                  builder: (context, snapshot) {
                    return Text(snapshot.hasData ? snapshot.data! : '');
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1)
              ],
            ),
          ),
        ),
        floatingActionButton: displaySave
            ? FloatingActionButton.extended(
                label: const Text('Save Diary Entry'),
                onPressed: () {
                  final count = context.read<AuthService>().diaryEntryCount++;
                  saveDiaryEntry(titleText, emotionTags, entryText, count);
                  setState(() {
                    context.read<AuthService>().isMicActive = false;
                  });
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return const DiarifyHome();
                    },
                  ));
                  // Show a Snackbar with the message "Diary Saved"
                  const snackBar = SnackBar(
                    backgroundColor: Colors.white,
                    content: Text('Diary Saved',
                        style: TextStyle(color: Colors.black)),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(Icons.save),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }
}
