// import 'package:cloud_functions/cloud_functions.dart';

// class DiarifyAPI {
//   final HttpsCallable _diarify =
//       FirebaseFunctions.instanceFor(region: 'us-central1')
//           .httpsCallable('diarifyV2');

//   Stream<String> callDiarify(String transcription) async* {
//     print(transcription);
//     try {
//       final result = await _diarify.call({
//         'transcription': transcription,
//       });
//       final String res = result.data['result'];
//       var tokens = result.data['tokens'];
//       print(tokens);
//       yield res; // Yield the result as a stream event.
//     } on FirebaseFunctionsException catch (e) {
//       yield 'Error occurred while calling diarify $e';
//     } catch (e) {
//       yield 'Unexpected error occurred $e';
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'dart:convert';

class DiarifyAPI {
  void callDiarifyV2(String transcription) async {
    var url = Uri.parse('https://diarifyv2-u22rx3qoaa-uc.a.run.app/diarifyV2');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'transcription': transcription,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      print('Response body: ${response.body}');
    } else {
      // If the server returns an unsuccessful response code,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void callDiarifyStream() async {
    var url = Uri.parse(
        'https://diarifystream-u22rx3qoaa-uc.a.run.app/diarifyStream');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // body: jsonEncode(<String, String>{
      //   'transcription': transcription,
      // }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      print(response.body);
    } else {
      // If the server returns an unsuccessful response code,
      // then throw an exception.
      throw Exception('Failed to load stream');
    }
  }
}
