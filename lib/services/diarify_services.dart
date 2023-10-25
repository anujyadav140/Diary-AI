import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diarify/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiarifyServices {
  Future<DocumentSnapshot?> getLatestDiaryEntry(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        // final date = DateTime.now();
        // final dateFormat = DateFormat("dd-MM-yyyy");
        // final dateFormatted = dateFormat.format(date);

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        final documentReference =
            collectionReference.doc(context.read<AuthService>().saveDiaryDate);
        final entryCollection = documentReference.collection("entries");

        // Query for the latest entry in descending order of time and limit to 1
        QuerySnapshot querySnapshot = await entryCollection
            .orderBy('time', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the latest entry
          return querySnapshot.docs.first;
        } else {
          print('No diary entries found for this date.');
          return null;
        }
      } else {
        print('User not signed in.');
        return null;
      }
    } catch (e) {
      print('Error getting latest diary entry: $e');
      return null;
    }
  }
}
//  displaySave
//             ? FloatingActionButton.extended(
//                 label: const Text('Save Diary Entry'),
//                 onPressed: () {
//                   context.read<AuthService>().diaryEntryCount =
//                       context.read<AuthService>().diaryEntryCount++;
//                   saveDiaryEntry(titleText, emotionTags, entryText,
//                       context.read<AuthService>().diaryEntryCount);
//                   setState(() {
//                     context.read<AuthService>().isMicActive = false;
//                   });
//                   Navigator.pushReplacement(context, MaterialPageRoute(
//                     builder: (context) {
//                       return const DiarifyHome();
//                     },
//                   ));
//                   // Show a Snackbar with the message "Diary Saved"
//                   const snackBar = SnackBar(
//                     backgroundColor: Colors.white,
//                     content: Text('Diary Saved',
//                         style: TextStyle(color: Colors.black)),
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 },
//                 icon: const Icon(Icons.save),
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//               )
//             : null,