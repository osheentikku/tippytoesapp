import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/3.%20parent_guardian_pages/account_page.dart';

//import 'admin_home_page.dart';
import 'admin_management_page.dart';
import 'admin_menu_page.dart';
import 'admin_reports_page.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({super.key});

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  List pages = [
    //const AdminHomePage(),
    const AdminMenuPage(),
    const AdminReportsPage(),
    const AdminManagementPage(),
    const AccountPage(),
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
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          //BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Classroom"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
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
