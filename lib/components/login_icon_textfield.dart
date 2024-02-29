import 'package:flutter/material.dart';

class LoginIconTextField extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final Icon preIcon;
  final double horizontalPadding;
  final double borderRadius;
  final double width;

  const LoginIconTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.preIcon,
    required this.screenHeight,
    required this.screenWidth,
    required this.horizontalPadding,
    required this.borderRadius,
    required this.width,
  });

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
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide:
                  BorderSide(color: Theme.of(context).secondaryHeaderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide:
                  BorderSide(color: Theme.of(context).secondaryHeaderColor),
            ),

            //filled color
            fillColor: Theme.of(context).secondaryHeaderColor,
            filled: true,

            //hints
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelMedium,
            prefixIcon: preIcon,
          ),
        ),
      ),
    );
  }
}
