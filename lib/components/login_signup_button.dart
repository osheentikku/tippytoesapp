import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSignupButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const LoginSignupButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 125),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 107, 95, 95)),
          ),
        ),
      ),
    );
  }
}
