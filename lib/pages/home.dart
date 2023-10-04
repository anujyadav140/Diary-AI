import 'dart:io';
import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:diarify/components/home_content.dart';
import 'package:diarify/components/slide_act.dart';
import 'package:diarify/components/audio_player.dart';
import 'package:diarify/pages/calender_diary.dart';
import 'package:diarify/pages/day_diary.dart';
import 'package:diarify/services/authservice.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiarifyHome extends StatefulWidget {
  const DiarifyHome({super.key});

  @override
  State<DiarifyHome> createState() => _DiarifyHomeState();
}

class _DiarifyHomeState extends State<DiarifyHome> {
  String displayName = '';
  String firstName = '';
  String profilePic = '';
  PageController pageController = PageController();
  int currentPage = 0; // Current page index
  @override
  void initState() {
    // Retrieve the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName!;
      profilePic = user.photoURL!;
      if (displayName.isNotEmpty) {
        // Split the full name by spaces and take the first part
        List<String> nameParts = displayName.split(' ');
        firstName = nameParts[0];
      }
    }
    pageController = PageController(initialPage: 1);
    currentPage = 1;
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose(); // Dispose the page controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text('Hi, $firstName',
              style: const TextStyle(color: Colors.white)),
          // title: Text('Hi, Ahir', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              radius: 200,
              backgroundImage: NetworkImage(profilePic),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                AuthService().logout();
              },
            ),
          ]),
      body: SafeArea(
        child: PageView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController, // Assign the page controller
          onPageChanged: (int page) {
            setState(() {
              currentPage = page; // Update the current page index
            });
          },
          children: const [
            DiarifyDay(),
            DiarifyHomeContent(),
            DiarifyCalender()
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        color:
            currentPage == 0 || currentPage == 2 ? Colors.white : Colors.black,
        backgroundColor:
            currentPage == 0 || currentPage == 2 ? Colors.black : Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        items: <Widget>[
          Icon(Icons.list,
              color: currentPage == 0 || currentPage == 2
                  ? Colors.black
                  : Colors.white,
              size: 30),
          Icon(Icons.add,
              color: currentPage == 0 || currentPage == 2
                  ? Colors.black
                  : Colors.white,
              size: 30),
          Icon(Icons.calendar_month,
              color: currentPage == 0 || currentPage == 2
                  ? Colors.black
                  : Colors.white,
              size: 30),
        ],
        onTap: (index) {
          // Handle button tap by changing the current page
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
