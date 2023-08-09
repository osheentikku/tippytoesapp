import 'package:flutter/material.dart';

class SignUpPasswordTextField extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final double horizontalPadding;
  final double borderRadius;

  const SignUpPasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
    required this.horizontalPadding,
    required this.borderRadius,
  });

  @override
  State<SignUpPasswordTextField> createState() =>
      _SignUpPasswordTextFieldState();
}

class _SignUpPasswordTextFieldState extends State<SignUpPasswordTextField> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: TextField(
        controller: widget.controller,
        obscureText: obscure,
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),

          //filled color
          fillColor: Theme.of(context).secondaryHeaderColor,
          filled: true,

          //hints
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.labelMedium,

          //hide/view
          suffixIcon: IconButton(
            icon: obscure
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                obscure = !obscure;
              });
            },
          ),
        ),
      ),
    );
  }
}
