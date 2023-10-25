import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraScreen extends StatefulWidget {
  final CameraController cameraController;

  const CameraScreen({super.key, required this.cameraController});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? capturedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: capturedImage == null
              ? CameraPreview(widget.cameraController)
              : Image.file(File(capturedImage!.path))),
      floatingActionButton: capturedImage == null
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                try {
                  final XFile photo =
                      await widget.cameraController.takePicture();
                  setState(() {
                    capturedImage = photo;
                  });
                } catch (e) {
                  print('Error taking a photo: $e');
                }
              },
              child: const Icon(Icons.camera, size: 20, color: Colors.black),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    setState(() {
                      capturedImage = null; // Clear the captured image
                    });
                  },
                  child:
                      const Icon(Icons.replay, size: 20, color: Colors.black),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    try {
                      final XFile photo =
                          await widget.cameraController.takePicture();
                      // Generate a unique image name
                      const uuid = Uuid();
                      String imageName = '${uuid.v4()}.jpg';

                      // Reference to the Firebase Storage bucket
                      Reference storageReference =
                          FirebaseStorage.instance.ref().child(imageName);

                      // Upload the image to Firebase Storage
                      await storageReference.putFile(File(photo.path));

                      print(
                          'Photo uploaded to Firebase Storage with name: $imageName');
                      Navigator.pop(context); // Close the camera screen
                    } catch (e) {
                      print('Error taking a photo or uploading it: $e');
                    }
                  },
                  child: const Icon(Icons.check, size: 20, color: Colors.black),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
