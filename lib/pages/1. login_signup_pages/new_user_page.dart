import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/signup_textfield.dart';
import 'package:change_case/change_case.dart';

import '../../components/show_message.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({
    super.key,
  });

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  //text editting controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  //account type
  bool isAdmin = false;
  bool isApproved = false;

  //user signup method
  Future userSignup() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      showMessage(context, "Please fill out all fields.");
    }
    //add user details
    try {
      User user = FirebaseAuth.instance.currentUser!;

      addUserDetails(
        firstNameController.text.trim().toCapitalCase(),
        lastNameController.text.trim().toCapitalCase(),
        user.email!,
        isAdmin,
        isApproved,
      );

      FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      showMessage(context, e.message.toString());
    }
  }


  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  Future addUserDetails(String firstName, String lastName, String email,
      bool isAdmin, bool isApproved) async {
    User user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      'First Name': firstName,
      'Last Name': lastName,
      'Email': email,
      'Admin': isAdmin,
      'Approved': isApproved,
    });
  }

  void setAdmin(bool? selectedValue) {
    if (selectedValue is bool) {
      setState(
        () {
          isAdmin = selectedValue;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffFECD08),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //pre padding
                SizedBox(height: screenHeight * 0.03),

                //create an account
                const Text(
                  "Finish creating your account",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                //padding
                SizedBox(height: screenHeight * 0.03),

                //first name
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: firstNameController,
                  hintText: "First Name",
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //last name
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: lastNameController,
                  hintText: "Last Name",
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //account type
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          "Admin",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          "Parent/Guardian",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ],
                    onChanged: setAdmin,
                    hint: const Text(
                      "Select account type",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    iconSize: 20,
                    decoration: InputDecoration(
                      //border
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: const BorderSide(color: Colors.white),
                      ),

                      //filled color
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //create an account
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Text(
                    "After your account is created, you will need to login again.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 158, 19, 9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                //padding
                SizedBox(height: screenHeight * 0.02),

                //signup
                LoginSignupButton(
                  text: 'Sign Up',
                  onTap: userSignup,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //or continue with
              ],
            ),
          ),
        ),
      ),
    );
  }
}
