import 'package:flutter/material.dart';

class SignupType extends StatelessWidget {
  const SignupType({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffFECD08),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //pre logo padding
              SizedBox(height: screenHeight * 0.03),

              //logo
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenWidth * 0.33,
                backgroundImage: AssetImage('lib/images/tippytoeslogo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
