import 'package:flutter/material.dart';

class ReportTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;

  const ReportTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, screenWidth * 0.07),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          //border
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: screenHeight * 0.003,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: screenHeight * 0.003,
            ),
          ),

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
