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
    //const HomePage(),
    const MenuPage(),
    const ReportsPage(),
    const ManagementPage(),
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
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return Scaffold(
      body: pages[currentIndex],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : BottomNavigationBar(
              items: const [
                //BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant), label: "Menu"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.description), label: "Reports"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Account"),
              ],
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).primaryColor,
              iconSize: 20,
              unselectedItemColor: Theme.of(context).hintColor,
              selectedItemColor: Colors.black,
              onTap: onTap,
            ),
    );
  }
}
