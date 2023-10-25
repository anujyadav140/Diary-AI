import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraScreen extends StatelessWidget {
  final CameraController cameraController;

  CameraScreen({required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CameraPreview(cameraController),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          try {
            final XFile photo = await cameraController.takePicture();

            // Generate a unique image name
            const uuid = Uuid();
            String imageName = '${uuid.v4()}.jpg';

            // Reference to the Firebase Storage bucket
            Reference storageReference =
                FirebaseStorage.instance.ref().child(imageName);

            // Upload the image to Firebase Storage
            await storageReference.putFile(File(photo.path));

            print('Photo uploaded to Firebase Storage with name: $imageName');
            Navigator.pop(context); // Close the camera screen
          } catch (e) {
            print('Error taking a photo or uploading it: $e');
          }
        },
        child: Icon(Icons.camera, size: 20, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
