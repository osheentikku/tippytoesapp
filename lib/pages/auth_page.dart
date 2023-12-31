import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/login_or_signup_page.dart';
import 'package:tippytoesapp/pages/check_approval_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //uncomment below line if interested in showing loading splash screen during sign in
          //if (snapshot.connectionState == ConnectionState.waiting)

          // User is logged in
          if (snapshot.hasData) {
            return const CheckApprovalPage();
          } else {
            // User is NOT logged in
            return const LoginOrSignupPage();
          }
        },
      ),
    );
  }
}
