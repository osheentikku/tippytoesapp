import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/apple_google_background.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/login_signup_textfield.dart';
import 'package:tippytoesapp/services/auth_service/auth_service.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  SignupPage({super.key, required this.onTap});

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
  bool approved = false;

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

    //check if password is confirmed
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Navigator.pop(context);
      showErrorMessage("Passwords don't match. Please try again.");
      return;
    }

    //try creating the user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      //pop loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //wrong login info
      showErrorMessage(e.message.toString());
    }
  }

  //error message popup
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 107, 95, 95),
              ),
            ),
          ),
        );
      },
    );
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
                //pre logo padding
                SizedBox(height: screenHeight * 0.03),

                Text(
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
                  height: screenHeight * 0.03,
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
                  height: screenHeight * 0.03,
                ),

                //email
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "Email",
                  obscure: false,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //password
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: passwordController,
                  hintText: "Password",
                  obscure: true,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //confirm password
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscure: true,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //login
                LoginSignupButton(
                  text: 'Sign Up',
                  onTap: userSignup,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //or continue with
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 116, 97, 97),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Color.fromARGB(255, 87, 73, 73),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 116, 97, 97),
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
                SizedBox(height: screenHeight * 0.05),

                //already have an account?
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
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
