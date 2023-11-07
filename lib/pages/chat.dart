import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DiarifyChat extends StatefulWidget {
  const DiarifyChat({super.key});

  @override
  State<DiarifyChat> createState() => _DiarifyChatState();
}

class _DiarifyChatState extends State<DiarifyChat> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  bool isUserTyping = true;
  bool isBotTyping = false;
  String chatResponse = '';
  final HttpsCallable _chatWithDiaryEntry =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('chatWithDiary');
  Future<String> callChatWithDiaryFunction(String question) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final result = await _chatWithDiaryEntry.call({
        'question': question,
        'user': user!.email,
      });

      final String res = result.data["response"]["text"];
      print(res);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling chatWithDiary $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  // Function to send a message
  void sendMessage() async {
    String userMessage = messageController.text;
    DateTime dateTime = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
    String formattedDateTime = formatter.format(dateTime);
    String userMessageRequest = '''Date and Time: $formattedDateTime\n
    $userMessage''';
    if (userMessage.isNotEmpty) {
      // Add the user's message
      setState(() {
        messages.add({
          'text': userMessage,
          'isUser': true,
        });
        messageController.clear();
        isUserTyping = false;
        isBotTyping = true;
      });
    }
    String chatResponse = await callChatWithDiaryFunction(userMessageRequest);
    getMessage(chatResponse);
  }

  void getMessage(String response) async {
    if (response.isNotEmpty) {
      setState(() {
        messages.add({
          'text': response,
          'isUser': false,
        });
        isBotTyping = false;
        isUserTyping = true;
      });
    }
  }

  // // Function to generate a random bot response
  // String getBotResponse(String userMessage) {
  //   final random = Random();
  //   final responses = [
  //     "I'm just a bot.",
  //     "How can I assist you today?",
  //     "Tell me more about your day.",
  //     "That's interesting!",
  //   ];
  //   return responses[random.nextInt(responses.length)];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with your diary ...',
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width / 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: messages.map((message) {
                  return Align(
                    alignment: message['isUser']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: message['isUser'] ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color:
                              message['isUser'] ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (isBotTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Typing...',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    enabled: isUserTyping,
                    decoration: const InputDecoration(
                      labelText: 'Ask a question ...',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    cursorColor: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, size: 30, color: Colors.black),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
