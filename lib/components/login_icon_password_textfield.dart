import 'package:flutter/material.dart';

class LoginIconPasswordTextField extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final Icon preIcon;

  const LoginIconPasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.preIcon,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<LoginIconPasswordTextField> createState() =>
      _LoginIconPasswordTextFieldState();
}

class _LoginIconPasswordTextFieldState
    extends State<LoginIconPasswordTextField> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.07),
      child: TextField(
        controller: widget.controller,
        obscureText: obscure,
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.screenWidth * 0.05),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.screenWidth * 0.05),
            borderSide:
                BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),

          //filled color
          fillColor: Theme.of(context).secondaryHeaderColor,
          filled: true,

          //hints
          labelText: widget.hintText,
          labelStyle: TextStyle(
            fontSize: 20,
            color: Theme.of(context).hintColor,
          ),
          prefixIcon: widget.preIcon,

          //hide/view
          suffixIcon: IconButton(
            icon: obscure
                ? const Icon(
                    Icons.visibility,
                  )
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
