import 'package:flutter/material.dart';

class GoogleAppleLogin extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;
  final double screenHeight;
  final double screenWidth;

  const GoogleAppleLogin({
    super.key,
    required this.onTap,
    required this.imagePath,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.01),
        height: 65,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenHeight * 0.01)),
        child: Image.asset(imagePath),
      ),
    );
  }
}
