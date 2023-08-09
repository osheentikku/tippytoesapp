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
  bool? isAdmin;
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
        isAdmin!,
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
      'Name': '$firstName $lastName',
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

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double borderRadius = 0;

  void setPadding(
      double small, double medium, double horizontal, double border) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
      borderRadius = border;
    });
  }

  @override
  Widget build(BuildContext context) {
    //get screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.07,
        screenWidth * 0.05);
    double dividerThickness = 0.5;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //pre padding
                SizedBox(height: paddingMedium),

                //create an account
                Text("Create an account",
                    style: Theme.of(context).textTheme.displayLarge),

                //padding
                SizedBox(height: paddingMedium),

                //first name
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: firstNameController,
                  hintText: "First Name",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //last name
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: lastNameController,
                  hintText: "Last Name",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //email
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "Email",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //password
                SignUpPasswordTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: passwordController,
                  hintText: "Password",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //confirm password
                SignUpPasswordTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //account type
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: Theme.of(context).secondaryHeaderColor),
                    child: DropdownButton(
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: true,
                          child: Text(
                            "Admin",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text(
                            "Parent/Guardian",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      value: isAdmin,
                      onChanged: setAdmin,
                      hint: Text(
                        "Select account type",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      iconSize: 20,
                      borderRadius: BorderRadius.circular(borderRadius),
                      dropdownColor: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //signup
                LoginSignupButton(
                  text: 'Sign Up',
                  onTap: userSignup,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  borderRadius: borderRadius,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //or continue with
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: dividerThickness,
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
                          thickness: dividerThickness,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),

                //padding
                SizedBox(height: paddingMedium),

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
                      width: paddingMedium,
                    ),

                    //apple logo
                    GoogleAppleLogin(
                      onTap: () => AuthService().signInWithApple(),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      imagePath: "lib/images/apple.png",
                    ),
                  ],
                ),

                //padding
                SizedBox(height: paddingMedium),

                //already have an account?
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          'Login now.',
                          style: Theme.of(context).textTheme.displayMedium,
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
