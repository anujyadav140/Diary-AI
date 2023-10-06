import 'dart:io';
import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:diarify/components/home_content.dart';
import 'package:diarify/components/slide_act.dart';
import 'package:diarify/components/audio_player.dart';
import 'package:diarify/pages/calender_diary.dart';
import 'package:diarify/pages/day_diary.dart';
import 'package:diarify/pages/diarify_generation.dart';
import 'package:diarify/services/authservice.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
  int currentPage = 0;
  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName!;
      profilePic = user.photoURL!;
      if (displayName.isNotEmpty) {
        List<String> nameParts = displayName.split(' ');
        firstName = nameParts[0];
      }
    }
    pageController = PageController(initialPage: 1, viewportFraction: 0.9999);
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
          title: currentPage == 0
              ? const Text('Diary Entries',
                  style: TextStyle(color: Colors.white))
              : Text('Hi, $firstName',
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
            currentPage == 0
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        context.read<AuthService>().isSelectDatesClicked =
                            !context.read<AuthService>().isSelectDatesClicked;
                      });
                    },
                    icon: Icon(
                      context.read<AuthService>().isSelectDatesClicked
                          ? Icons.calendar_today
                          : Icons.calendar_today_outlined,
                      color: Colors.white,
                      size: 30,
                    ))
                : IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // AuthService().logout();
                    },
                  ),
          ]),
      body: SafeArea(
        child: PageView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              currentPage = value;
            });
          },
          children: [
            Consumer(
              builder: (context, value, child) {
                return DiarifyDay(
                  isSelectDatesClicked:
                      context.read<AuthService>().isSelectDatesClicked,
                );
              },
            ),
            const DiarifyHomeContent(),
            const DiarifyCalender()
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentPage,
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
          setState(() {
            currentPage = index;
          });
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
