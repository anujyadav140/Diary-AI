import 'package:diarify/authentication/authgate.dart';
import 'package:diarify/firebase_options.dart';
import 'package:diarify/pages/diarify_generation.dart';
import 'package:diarify/pages/home.dart';
import 'package:diarify/pages/login.dart';
import 'package:diarify/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Diarify AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoMonoTextTheme(textTheme),
      ),
      debugShowCheckedModeBanner: false,
      // home: const DiarifyHome(),
      home: const AuthGate(),
      // home: DiarifyGeneration(
      //   path: '',
      // ),
    );
  }
}
