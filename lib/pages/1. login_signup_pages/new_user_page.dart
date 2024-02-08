import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/signup_textfield.dart';
import 'package:change_case/change_case.dart';

import '../../components/show_message.dart';
import '../check_approval_page.dart';

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
  bool? isAdmin;
  bool redirect = false;

  bool isApproved = false;

  //user signup method
  Future userSignup() async {
    if (isAdmin == null) {
      showMessage(context, "Please select an account type");
    } else {
      try {
        User user = FirebaseAuth.instance.currentUser!;


        await addUserDetails(
          firstNameController.text.trim().toCapitalCase(),
          lastNameController.text.trim().toCapitalCase(),
          user.email!,
          isAdmin!,
          isApproved,
        );

        setState(() {
          redirect = true;
        });
      } on FirebaseAuthException catch (e) {
        showMessage(context, e.message.toString());
      }
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

    if (redirect) {
      return const CheckApprovalPage();
    } else {
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
                  Text("Finish creating your account",
                      style: Theme.of(context).textTheme.displayLarge),

                  //padding
                  SizedBox(height: screenHeight * 0.03),

<<<<<<< Updated upstream
                  //create an account
                  Padding(
=======
                //first name
                SignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: firstNameController,
                  hintText: "First Name",
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                  width: screenHeight * 0.7,
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
                  width: screenHeight * 0.7,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //account type
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
>>>>>>> Stashed changes
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(
                      "Providing your name is not required but highly reccomended to ease communication.",
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
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

                  //account type
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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

                  //padding
                  SizedBox(height: paddingMedium),

<<<<<<< Updated upstream
                  //signup
                  LoginSignupButton(
                    text: 'Sign Up',
                    onTap: userSignup,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    borderRadius: borderRadius,
                  ),
=======
                //signup
                LoginSignupButton(
                  text: 'Sign Up',
                  onTap: userSignup,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  borderRadius: borderRadius,
                  width: screenHeight * 0.2,
                ),
>>>>>>> Stashed changes

                  //padding
                  SizedBox(
                    height: paddingMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
