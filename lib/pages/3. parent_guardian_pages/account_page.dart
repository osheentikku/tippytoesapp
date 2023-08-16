import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/account_textfield.dart';

import '../../components/show_message.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  //text editing controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  //user
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    populateFields();
  }

  //fill out profile fields
  Future populateFields() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    String name = documentSnapshot['Name'];
    int spacePosition = name.indexOf(" ");

    firstNameController.text = name.substring(0, spacePosition);
    lastNameController.text = name.substring(spacePosition + 1);
    emailController.text = documentSnapshot["Email"];
  }

  Future editUserDetails(
      String firstName, String lastName, String email) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      'Name': '$firstName $lastName',
      'Email': email,
    });
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

  //save student data to Firestore
  Future saveProfile() async {
    //loading
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //fields need to be filled
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      showMessage(context, "Please fill out all fields.");
    } else {
      try {
        //changing email
        if (user.email != emailController.text.trim()) {
          await user.updateEmail(emailController.text.trim());
          editUserDetails(
              firstNameController.text.trim().toCapitalCase(),
              lastNameController.text.trim().toCapitalCase(),
              emailController.text.trim());
        } else {
          editUserDetails(firstNameController.text.trim().toCapitalCase(),
              lastNameController.text.trim().toCapitalCase(), user.email!);
        }
        //pop loading circle
        if (mounted) {
          Navigator.pop(context);
          showMessage(context, "Changes made succesfully");
        }
      } on FirebaseAuthException catch (e) {
        //pop loading circle
        if (mounted) {
          Navigator.pop(context);
        }
        showMessage(context, e.message.toString());
      }
    }
    populateFields();
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;

  void setPadding(
      double small, double medium, double horizontal) {
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
    setPadding(screenHeight * 0.005, screenHeight * 0.02,
        screenWidth * 0.07);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: screenWidth * 0.2,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenWidth * 0.3,
                  ),
                ),
                SizedBox(
                  height: paddingMedium,
                ),

                Text(
                  "Edit profile",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                SizedBox(
                  height: paddingMedium,
                ),

                //first name
                AccountTextField(
                  controller: firstNameController,
                  hintText: "First Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                ),

                SizedBox(
                  height: paddingMedium,
                ),

                //last name
                AccountTextField(
                  controller: lastNameController,
                  hintText: "Last Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                ),

                SizedBox(
                  height: paddingMedium,
                ),

                //email
                AccountTextField(
                  controller: emailController,
                  hintText: "Email",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                ),

                SizedBox(
                  height: paddingMedium,
                ),

                //save button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: MaterialButton(
                    onPressed: () => saveProfile(),
                    padding: EdgeInsets.all(paddingSmall),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text(
                          "Save",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                ),

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
          ),
        ),
      ),
    );
  }
}
