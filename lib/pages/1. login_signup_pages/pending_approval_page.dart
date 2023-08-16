import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  //user
  User user = FirebaseAuth.instance.currentUser!;

//for testing purposes
  void userLogout() {
    FirebaseAuth.instance.signOut();
  }

  void deleteAccount() {
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
                //delete from students
                DocumentSnapshot documentSnapshot = await FirebaseFirestore
                    .instance
                    .collection("users")
                    .doc(user.uid)
                    .get();

                String name = documentSnapshot['Name'];
                String email = documentSnapshot["Email"];

                String studentName = documentSnapshot["Student"] ?? "";
                if (studentName.isNotEmpty) {
                  DocumentSnapshot studentSnapshot = await FirebaseFirestore
                      .instance
                      .collection("students")
                      .doc(studentName)
                      .get();

                  List<String> parents =
                      List<String>.from(studentSnapshot["ParentOrGuardian"]);
                  parents.remove("$name: $email");

                  //delete document
                  await FirebaseFirestore.instance
                      .collection("students")
                      .doc(studentName)
                      .update({"ParentOrGuardian": parents});
                }

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

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;

  void setPadding(double small, double medium, double horizontal) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.07);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Center(child: Text("Your account is still pending approval.")),
          //delete button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: MaterialButton(
              onPressed: () => deleteAccount(),
              padding: EdgeInsets.all(paddingSmall),
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
    );
  }
}
