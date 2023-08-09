import 'package:flutter/material.dart';

class ManagementTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final double horizontalPadding;

  const ManagementTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
    );
  }
}
