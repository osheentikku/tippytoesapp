import 'package:flutter/material.dart';

class ManagementPasswordTextField extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;

  const ManagementPasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<ManagementPasswordTextField> createState() =>
      _ManagementPasswordTextFieldState();
}

class _ManagementPasswordTextFieldState
    extends State<ManagementPasswordTextField> {
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
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: widget.screenHeight * 0.003,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xffFECD08),
              width: widget.screenHeight * 0.003,
            ),
          ),

          //filled color

          //hints
          labelText: widget.hintText,
          labelStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),

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
