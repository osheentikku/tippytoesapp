import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/login_page.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/signup_page.dart';

class LoginOrSignupPage extends StatefulWidget {
  const LoginOrSignupPage({super.key});

  @override
  State<LoginOrSignupPage> createState() => _LoginOrSignupPageState();
}

class _LoginOrSignupPageState extends State<LoginOrSignupPage> {
  //initially show login page
  bool showLoginPage = true;

  //toggle between login and signup page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return SignupPage(onTap: togglePages);
    }
  }
}
