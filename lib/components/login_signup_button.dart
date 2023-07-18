import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSignupButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final screenHeight;
  final screenWidth;

  const LoginSignupButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.015),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 107, 95, 95)),
          ),
        ),
      ),
    );
  }
}
