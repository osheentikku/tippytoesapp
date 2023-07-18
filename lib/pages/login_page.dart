import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/apple_google_background.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/login_signup_textfield.dart';
import 'package:tippytoesapp/services/auth_service/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editting controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //user login method
  void userLogin() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      //pop loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);

      //wrong login info
      loginErrorMessage();
    }
  }

  //wrong email/password message popup
  void loginErrorMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Your username or password is incorrect. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
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

                //logo
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: screenWidth * 0.33,
                  backgroundImage: AssetImage('lib/images/tippytoeslogo'),
                ),

                //padding
                SizedBox(height: screenHeight * 0.03),

                //email
                LoginSignUpTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "email",
                  obscure: false,
                  preIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: Colors.black,
                    size: screenHeight * 0.035,
                  ),
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
                  hintText: "password",
                  obscure: true,
                  preIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.black,
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
                      Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 18),
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

                //dont have an account?
                //forgot password
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: screenWidth * 0.01,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Sign up.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
