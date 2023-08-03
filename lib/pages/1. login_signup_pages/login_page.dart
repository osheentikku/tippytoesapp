import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/apple_google_background.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/login_icon_textfield.dart';
import 'package:tippytoesapp/components/show_message.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/forgot_password_page.dart';
import 'package:tippytoesapp/services/auth_service/auth_service.dart';

import '../../components/login_icon_password_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editting controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //user login method
  Future userLogin() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //get screen height and width
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
                //pre logo padding
                SizedBox(height: screenHeight * 0.03),

                //logo
                CircleAvatar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  radius: screenWidth * 0.33,
                  backgroundImage: const AssetImage('lib/images/tippytoeslogo'),
                ),

                //padding
                SizedBox(height: screenHeight * 0.03),

                //email
                LoginIconTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "Email",
                  preIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: Theme.of(context).primaryIconTheme.color,
                    size: screenHeight * 0.035,
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //password
                LoginIconPasswordTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: passwordController,
                  hintText: "Password",
                  preIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).primaryIconTheme.color,
                    size: screenHeight * 0.035,
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.008,
                ),

                //forgot password
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ForgotPasswordPage();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                //pading
                SizedBox(height: screenHeight * 0.03),

                //login
                LoginSignupButton(
                  text: 'LOGIN',
                  onTap: userLogin,
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
                SizedBox(height: screenHeight * 0.05),

                //dont have an account?
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        const Text(
                          'Sign up.',
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
