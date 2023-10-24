import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class DiarifyServices {
  Future<DocumentSnapshot?> getLatestDiaryEntry() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        final date = DateTime.now();
        final dateFormat = DateFormat("dd-MM-yyyy");
        final dateFormatted = dateFormat.format(date);

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        final documentReference = collectionReference.doc(dateFormatted);
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
