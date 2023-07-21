import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //for testing purposes
  void userLogout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: userLogout, icon: Icon(Icons.logout))
      ]),
      body: Center(
        child: Text(
            "Logged in as:" + user.email! + ". You are a parent/guardian."),
      ),
    );
  }
}
