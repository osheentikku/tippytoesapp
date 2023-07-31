import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/2.%20admin_pages/admin_navigation_page.dart';
import 'package:tippytoesapp/pages/1.%20login_signup_pages/new_user_page.dart';
import 'package:tippytoesapp/pages/3.%20parent_guardian_pages/navigation_page.dart';

class RoleBasedPage extends StatefulWidget {
  const RoleBasedPage({super.key});

  @override
  State<RoleBasedPage> createState() => _RoleBasedPageState();
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
      return const AdminNavigationPage();
    } else {
      return const NavigationPage();
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
