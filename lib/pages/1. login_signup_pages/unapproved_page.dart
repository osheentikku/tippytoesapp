import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnapprovedPage extends StatefulWidget {
  const UnapprovedPage({super.key});

  @override
  State<UnapprovedPage> createState() => _UnapprovedPageState();
}

//for testing purposes
void userLogout() {
  FirebaseAuth.instance.signOut();
}

class _UnapprovedPageState extends State<UnapprovedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: const Color(0xffFECD08),
        elevation: 0,
      ),
      body: Center(child: Text("Your account is still pending approval.")),
    );
  }
}
