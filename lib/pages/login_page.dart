import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_signup_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editting controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFECD08),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //pre logo padding
              SizedBox(height: 40),

              //logo
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 150,
                backgroundImage: AssetImage('lib/images/tippytoeslogo'),
              ),

              //padding
              SizedBox(height: 50),

              //email
              LoginSignUpTextField(
                controller: usernameController,
                hintText: "email",
                obscure: false,
                preIcon: Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.black,
                  size: 35,
                ),
              ),

              //padding
              SizedBox(
                height: 40,
              ),

              //password
              LoginSignUpTextField(
                controller: passwordController,
                hintText: "password",
                obscure: true,
                preIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.black,
                  size: 35,
                ),
              ),
              //forgot password

              //login

              //apple/google row

              //dont have an account?
            ],
          ),
        ),
      ),
    );
  }
}
