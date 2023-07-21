import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/admin_home_page.dart';

import 'home_page.dart';

class RoleBasedPage extends StatefulWidget {
  @override
  _RoleBasedPageState createState() => _RoleBasedPageState();
}

class _RoleBasedPageState extends State<RoleBasedPage> {
  // Function to check if the current user is an admin or not in Firestore
  Future<bool> checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('Admin') ?? false;
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
    bool isAdmin = await checkUserRole();
    if (isAdmin) {
      return AdminHomePage();
    } else {
      return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Widget>(
        // Invoke the function to determine the page to show
        future: checkAndRedirect(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              // Show a loading indicator while checking user role
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle error if needed
            return Center(
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
