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

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).primaryIconTheme.color),
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
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  radius: screenHeight * 0.23,
                  backgroundImage: const AssetImage('lib/images/tippytoeslogo'),
                ),

                //padding
                SizedBox(height: paddingMedium),

                //email
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    "Enter your email and we will send you a password reset link.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //padding
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
                  horizontalPadding: horizontalPadding,
                  borderRadius: borderRadius,
                  width: screenHeight * 0.7,
                ),

                //enter email instructions
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //Reset Password Button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: MaterialButton(
                    onPressed: () => passwordReset(),
                    padding: EdgeInsets.all(screenHeight * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: Text("Reset Password",
                        style: Theme.of(context).textTheme.displayLarge),
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
