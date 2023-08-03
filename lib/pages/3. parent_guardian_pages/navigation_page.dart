import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/3.%20parent_guardian_pages/reports_page.dart';

import 'home_page.dart';
import 'management_page.dart';
import 'menu_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  List pages = [
    const HomePage(),
    const MenuPage(),
    const ReportsPage(),
    const ManagementPage(),
  ];

  int currentIndex = 2;
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
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: const Color(0xffFECD08),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xffFECD08),
        iconSize: 35,
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.black,
        onTap: onTap,
      ),
    );
  }
}
