import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/unapproved_page.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/new_user_page.dart';
import 'package:tippytoesapp/pages/rolebased_page.dart';

class CheckApprovalPage extends StatefulWidget {
  const CheckApprovalPage({super.key});

  @override
  State<CheckApprovalPage> createState() => _CheckApprovalPageState();
}

class _CheckApprovalPageState extends State<CheckApprovalPage> {
//check if user has info stored in Firestore
  Future<bool> checkUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.exists;
    }
    return false;
  }

  // Function to check if the current user is an admin or not in Firestore
  Future<bool> checkUserApproval() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('Approved') ?? false;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    checkAndRedirect();
  }

  // Function to check user role and redirect accordingly
  Future<Widget> checkAndRedirect() async {
    bool oldUser = await checkUserData();
    if (!oldUser && context.mounted) {
      return const NewUserPage();
    } else {
      bool isApproved = await checkUserApproval();
      if (isApproved) {
        return const RoleBasedPage();
      } else {
        return const UnapprovedPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<Widget>(
        // Invoke the function to determine the page to show
        future: checkAndRedirect(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              // Show a loading indicator while checking user role
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle error if needed
            return const Center(
              child: Text('Error occurred while checking user role.'),
            );
          } else {
            // If the check is completed, return the determined page,
            // or an empty Container if no page is returned
            return snapshot.data ?? Container();
          }
        },
      ),
    );
  }
}
