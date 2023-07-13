import 'package:flutter/material.dart';

class AppleGoogleBackground extends StatelessWidget {
  final String imagePath;

  const AppleGoogleBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Image.asset(imagePath),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
    );
  }
}
