import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/apple_google_background.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/signup_password_textfield.dart';
import 'package:tippytoesapp/components/signup_textfield.dart';
import 'package:tippytoesapp/services/auth_service/auth_service.dart';
import 'package:change_case/change_case.dart';

import '../../components/show_message.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //text editting controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //account type
  bool isAdmin = false;
  bool isApproved = false;

  //user signup method
  Future userSignup() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage(context, "Please fill out all fields.");
    }

    //check if password is confirmed
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Navigator.pop(context);
      showMessage(context, "Passwords don't match. Please try again.");
      return;
    }

    //try creating the user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      //add user details
      addUserDetails(
        firstNameController.text.trim().toCapitalCase(),
        lastNameController.text.trim().toCapitalCase(),
        emailController.text.trim().toLowerCase(),
        isAdmin,
        isApproved,
      );

      //pop loading circle
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //wrong login info
      showMessage(context, e.message.toString());
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
      backgroundColor: Theme.of(context).primaryColor,
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

                //email
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "Email",
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //password
                SignUpPasswordTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: passwordController,
                  hintText: "Password",
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //confirm password
                SignUpPasswordTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
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
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          "Parent/Guardian",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                    onChanged: setAdmin,
                    hint: Text(
                      "Select account type",
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).hintColor),
                    ),
                    iconSize: 20,
                    decoration: InputDecoration(
                      //border
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(
                            color: Theme.of(context).secondaryHeaderColor),
                      ),

                      //filled color
                      fillColor: Theme.of(context).secondaryHeaderColor,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //apple/google logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google logo
                    GoogleAppleLogin(
                      onTap: () => AuthService().signInWithGoogle(),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      imagePath: "lib/images/google.png",
                    ),

                    //spacing
                    SizedBox(
                      width: screenWidth * 0.07,
                    ),

                    //apple logo
                    GoogleAppleLogin(
                      onTap: () => AuthService().signInWithGoogle(),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      imagePath: "lib/images/apple.png",
                    ),
                  ],
                ),

                //padding
                SizedBox(height: screenHeight * 0.03),

                //already have an account?
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        const Text(
                          'Login now.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
