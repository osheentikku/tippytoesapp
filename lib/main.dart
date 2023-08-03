import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tippy Toes Daycare',
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: const Color(0xffFECD08),
        secondaryHeaderColor: Colors.white,
        primaryIconTheme: const IconThemeData(color: Colors.black),
        dividerColor: const Color.fromARGB(255, 78, 64, 64),
        hintColor: Colors.black54
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
