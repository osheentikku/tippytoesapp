import 'package:flutter/material.dart';

class ManagementTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;

  const ManagementTextField({
    super.key,
    required this.controller,
    required this.hintText,
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
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: screenHeight * 0.003,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: screenHeight * 0.003,
            ),
          ),

          //filled color

          //hints
          labelText: hintText,
          labelStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
