import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';

void main() {
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
        fontFamily: GoogleFonts.inter().fontFamily, 
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
