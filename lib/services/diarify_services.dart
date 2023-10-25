import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diarify/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DiarifyServices {
  Future<void> saveDiaryEntry(String title, List<String> emotionTags,
      String entry, int count, String link, BuildContext context) async {
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
        await diarifyDatePointer(dateFormatted);

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
          'link': link,
        });

        print('Diary entry saved successfully.');
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error saving diary entry: $e');
    }
  }

  Future<void> diarifyDatePointer(String date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        // Create a document with the name "diarifyDate"
        final documentReference = collectionReference.doc("diarifyDate");

        // Set the "date" field with the value "23-10-23"
        await documentReference.set({"date": date});
      }
    } catch (e) {
      // Handle any potential errors
      print("Error: $e");
    }
  }

  Future<String?> getDiarifyDatePointer(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        // Get the "diarifyDate" document
        final documentReference = collectionReference.doc("diarifyDate");

        final documentSnapshot = await documentReference.get();

        if (documentSnapshot.exists) {
          // If the document exists, return the "date" field
          final date = documentSnapshot.get("date");
          return date;
        } else {
          // The document does not exist
          return null;
        }
      } else {
        // User is not authenticated
        return null;
      }
    } catch (e) {
      // Handle any potential errors
      print("Error: $e");
      return null;
    }
  }

  Future<DocumentSnapshot?> getLatestDiaryEntry(String? date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;

        final collectionReference =
            FirebaseFirestore.instance.collection(userEmail!);

        final documentReference = collectionReference.doc(date);
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

  String imageDownloadUrl = '';
  Future<void> uploadImageToFirebase(XFile photo, BuildContext context) async {
    try {
      // Generate a unique image name
      const uuid = Uuid();
      String imageName = '${uuid.v4()}.jpg';

      // Reference to the Firebase Storage bucket
      Reference storageReference =
          FirebaseStorage.instance.ref().child(imageName);

      // Upload the image to Firebase Storage
      await storageReference.putFile(File(photo.path));

      // Get the download URL for the uploaded image
      imageDownloadUrl = await storageReference.getDownloadURL();
      // ignore: use_build_context_synchronously
      context.read<AuthService>().diarifyImageLink = imageDownloadUrl;
      // ignore: use_build_context_synchronously
      context.read<AuthService>().imageDone = true;
      print(
          // ignore: use_build_context_synchronously
          'Photo uploaded to Firebase Storage with link: ${context.read<AuthService>().diarifyImageLink}');
    } catch (e) {
      print('Error taking a photo or uploading it: $e');
    }
  }
}
