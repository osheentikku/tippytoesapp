import 'package:flutter/material.dart';

class ReportTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final double horizontalPadding;
  final double textfieldBorder;

  const ReportTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
    required this.horizontalPadding,
    required this.textfieldBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, horizontalPadding),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          //border
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: textfieldBorder,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: textfieldBorder,
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
