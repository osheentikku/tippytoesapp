import 'package:flutter/material.dart';

class AccountTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final double horizontalPadding;
  final double width;

  const AccountTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.screenHeight,
      required this.screenWidth,
      required this.horizontalPadding,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: width,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            //border
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),

            //hints
            labelText: hintText,
            labelStyle: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
