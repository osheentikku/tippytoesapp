import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/login_signup_textfield.dart';
import 'package:change_case/change_case.dart';

class NewUserPage extends StatefulWidget {
  final User user;
  NewUserPage({super.key, required this.user});

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
  void userSignup() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //add user details
    addUserDetails(
      firstNameController.text.trim().toCapitalCase(),
      lastNameController.text.trim().toCapitalCase(),
      widget.user.email!,
      isAdmin,
      isApproved,
    );

    Navigator.pop(context);
  }

  void addUserDetails(String firstName, String lastName, String email,
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
      backgroundColor: Color(0xffFECD08),
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
                  "Create an account",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                //padding
                SizedBox(height: screenHeight * 0.03),

                //first name
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: firstNameController,
                  hintText: "First Name",
                  obscure: false,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //last name
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: lastNameController,
                  hintText: "Last Name",
                  obscure: false,
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
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(color: Colors.white),
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
