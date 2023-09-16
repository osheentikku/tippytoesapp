import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UnapprovedPage extends StatefulWidget {
  const UnapprovedPage({super.key});

  @override
  State<UnapprovedPage> createState() => _UnapprovedPageState();
}

class _UnapprovedPageState extends State<UnapprovedPage> {
  void deleteAccount() {
    User user = FirebaseAuth.instance.currentUser!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          title: Center(
            child: Text("Confirmation",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          content: Text(
              "Are you sure you want to delete your account? All data associated with your account will be deleted too.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () async {
                //delete document
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .delete();

                await user.delete();

                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Yes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "No",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        actions: const [
          IconButton(onPressed: userLogout, icon: Icon(Icons.logout)),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your account is still pending approval."),
            SizedBox(height: screenHeight * 0.03),
            //delete button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: MaterialButton(
                onPressed: () => deleteAccount(),
                padding: EdgeInsets.all(screenHeight * 0.005),
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete),
                    Text(
                      "Delete Account",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//for testing purposes
void userLogout() {
  FirebaseAuth.instance.signOut();
}
