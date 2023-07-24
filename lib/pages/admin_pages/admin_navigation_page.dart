import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_home_page.dart';
import 'admin_management_page.dart';
import 'admin_menu_page.dart';
import 'admin_updates_page.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({super.key});

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  List pages = [
    AdminHomePage(),
    AdminMenuPage(),
    AdminUpdatesPage(),
    AdminManagementPage(),
  ];

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final user = FirebaseAuth.instance.currentUser!;

  //for testing purposes
  void userLogout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: Icon(Icons.logout)),
        ],
        backgroundColor: Color(0xffFECD08),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Updates"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xffFECD08),
        iconSize: 35,
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.black,
        onTap: onTap,
      ),
    );
  }
}
