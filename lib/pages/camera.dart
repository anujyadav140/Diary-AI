import 'dart:io';
import 'package:diarify/services/diarify_services.dart';
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
  String? imageDownloadUrl;
  FlashMode flashMode = FlashMode.off; // Set flash mode to "off"

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                widget.cameraController.setFlashMode(FlashMode.auto);
                try {
                  final XFile photo =
                      await widget.cameraController.takePicture();
                  setState(() {
                    capturedImage = photo;
                  });
                  widget.cameraController.setFlashMode(FlashMode.off);
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
                    await DiarifyServices()
                        .uploadImageToFirebase(capturedImage!, context);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.check, size: 20, color: Colors.black),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
