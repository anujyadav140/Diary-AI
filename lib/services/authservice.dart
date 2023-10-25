import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class AuthService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //login user
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      //login
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firestore.collection('users').doc(userCredential.user!.uid).set(
          ({
            'uid': userCredential.user!.uid,
            'email': email,
          }),
          SetOptions(merge: true));
      return userCredential;
      //catch any errors
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  signInWithGoogle() async {
    print('signing in with google');
    //begin sign in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    //obtain auth details
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    //sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //create a new user
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //after user creation create a doc on firestore
      _firestore.collection('users').doc(userCredential.user!.uid).set(({
            'uid': userCredential.user!.uid,
            'email': email,
          }));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //logout user
  Future<void> logout() async {
    return await FirebaseAuth.instance.signOut();
  }

  //toke state change
  int tokenCounterValue = 0;
  bool tokenAuth = true;
  Future<int> tokenCounter(String currentUserUid) async {
    tokenCounterValue++;
    if (tokenCounterValue >= 5) {
      tokenAuth = false;
    }
    try {
      //after state change store it in firestore
      _firestore.collection('users-state').doc(currentUserUid).set(({
            'tokenCount': tokenCounterValue,
            'tokenBoolean': tokenAuth,
          }));
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }

    return tokenCounterValue;
  }

  bool _isSelectDatesClicked = false;

  bool get isSelectDatesClicked => _isSelectDatesClicked;

  set isSelectDatesClicked(bool value) {
    _isSelectDatesClicked = value;
    notifyListeners();
  }

  int _diaryEntryCount = 1;
  int get diaryEntryCount => _diaryEntryCount;
  set diaryEntryCount(int value) {
    _diaryEntryCount = value;
    notifyListeners();
  }

  int _currentDayIndex = 1;

  int get currentDayIndex => _currentDayIndex;

  set currentDayIndex(int value) {
    _currentDayIndex = value;
    notifyListeners();
  }

  String _saveDiaryDate = '23-10-2023';
  String get saveDiaryDate => _saveDiaryDate;
  set saveDiaryDate(String value) {
    _saveDiaryDate = value;
    notifyListeners();
  }

  bool _isMicActive = false;
  bool get isMicActive => _isMicActive;
  set isMicActive(bool value) {
    _isMicActive = value;
    notifyListeners();
  }

  DiarySettingsModel _settings = DiarySettingsModel();

  DiarySettingsModel get settings => _settings;

  set settings(DiarySettingsModel value) {
    _settings = value;
    notifyListeners();
  }
}

class DiarySettingsModel {
  String selectedWordLimit = '250';
  String selectedStyle = 'Casual';
  String selectedTry = 'Be factual';
  String selectedEmotionTags = 'Yes';
  String selectedInspirationalQuotes = 'No';
  String additionalDirections = '';
}
