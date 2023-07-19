import 'package:flutter/material.dart';

class LoginSignUpTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final bool obscure;

  const LoginSignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            borderSide: BorderSide(color: Colors.white),
          ),

          //filled color
          fillColor: Colors.white,
          filled: true,

          //hints
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
