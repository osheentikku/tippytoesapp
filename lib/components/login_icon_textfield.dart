import 'package:flutter/material.dart';

class LoginIconTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final Icon preIcon;

  const LoginIconTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.preIcon,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),

          //filled color
          fillColor: Theme.of(context).secondaryHeaderColor,
          filled: true,

          //hints
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 20,
            color: Theme.of(context).hintColor,
          ),
          prefixIcon: preIcon,
        ),
      ),
    );
  }
}
