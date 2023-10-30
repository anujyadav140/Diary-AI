import 'package:cloud_functions/cloud_functions.dart';

class Tester {
  final HttpsCallable _lineFinisher =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('lineFinisher');

  Future<String> callLineFinisherFunction(String poem) async {
    try {
      final result = await _lineFinisher.call({
        'poem': poem,
      });
      String res = result.data['result'];
      print("hello world");
      print(res);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling lineFinisher $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _myFunction =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('myFunction');
  Future<void> callCloudFunction() async {
    try {
      final response = await _myFunction.call({
        'entry': "what is Anuj's astrological sign?",
      });
      print('Response from Cloud Function: ${response.data}');
    } catch (e) {
      print('Error calling Cloud Function: $e');
    }
  }

  final HttpsCallable _helloWorld =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('helloWorld');

  Future<void> callHelloFunction() async {
    try {
      final response = await _helloWorld.call();
      print('Response from Cloud Function: ${response.data}');
    } catch (e) {
      print('Error calling Cloud Function: $e');
    }
  }
}
