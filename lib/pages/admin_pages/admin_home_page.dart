import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/admin_pages/admin_management_page.dart';
import 'package:tippytoesapp/pages/admin_pages/admin_menu_page.dart';
import 'package:tippytoesapp/pages/admin_pages/admin_updates_page.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  //for testing purposes
  void userLogout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text("Logged in as:" + user.email! + ". You are an admin."),
      ),
    );
  }
}
