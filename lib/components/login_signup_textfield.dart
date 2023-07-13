import 'package:flutter/material.dart';

class LoginSignUpTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscure;
  final Icon preIcon;

  const LoginSignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.preIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.white),
          ),

          //filled color
          fillColor: Colors.white,
          filled: true,

          //hints
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
          prefixIcon: preIcon,
        ),
      ),
    );
  }
}
