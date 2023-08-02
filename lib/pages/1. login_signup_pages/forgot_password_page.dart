import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_icon_textfield.dart';

import '../../components/show_message.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  //text editting controllers
  final emailController = TextEditingController();

  Future passwordReset() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try sending reset link
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      //pop loading circle
      if (mounted) {
        Navigator.pop(context);
      }

      //successful reset
      if (mounted) {
        showMessage(context,
            "Password reset link sent to ${emailController.text.trim()}. Check your email.");
      }
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);

      showMessage(context, e.message.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //get screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffFECD08),
      appBar: AppBar(
        backgroundColor: const Color(0xffFECD08),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        toolbarHeight: screenHeight * 0.05,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: screenWidth * 0.33,
                  backgroundImage: const AssetImage('lib/images/tippytoeslogo'),
                ),

                //padding
                SizedBox(height: screenHeight * 0.04),

                //email
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Text(
                    "Enter your email and we will send you a password reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //padding
                LoginIconTextField(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  controller: emailController,
                  hintText: "Email",
                  preIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: Colors.black,
                    size: screenHeight * 0.035,
                  ),
                ),

                //enter email instructions
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //Reset Password Button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
                  child: MaterialButton(
                    onPressed: () => passwordReset(),
                    padding: EdgeInsets.all(screenHeight * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    color: Colors.white,
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                //pading
                SizedBox(height: screenHeight * 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
