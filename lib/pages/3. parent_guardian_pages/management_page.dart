import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/managment_textfield.dart';

import '../../components/show_message.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
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

    firstNameController.text = documentSnapshot["First Name"];
    lastNameController.text = documentSnapshot["Last Name"];
    emailController.text = documentSnapshot["Email"];
  }

  Future editUserDetails(
      String firstName, String lastName, String email) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      'First Name': firstName,
      'Last Name': lastName,
      'Email': email,
    });
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: screenHeight * 0.03,
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
                  height: screenHeight * 0.01,
                ),

                const Text(
                  "Edit profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),

                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //first name
                ManagementTextField(
                  controller: firstNameController,
                  hintText: "First Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //last name
                ManagementTextField(
                  controller: lastNameController,
                  hintText: "Last Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //email
                ManagementTextField(
                  controller: emailController,
                  hintText: "Email",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //save button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: MaterialButton(
                    onPressed: () => saveProfile(),
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    color: Theme.of(context).primaryColor,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text(
                          "Save",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
