import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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

              //email
              
              //password
              
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
