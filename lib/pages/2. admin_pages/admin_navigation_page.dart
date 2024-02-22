import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/pages/2.%20admin_pages/admin_announcement_page.dart';
import 'package:tippytoesapp/pages/3.%20parent_guardian_pages/account_page.dart';

//import 'admin_home_page.dart';
import 'admin_classroom_page.dart';
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
    const AdminAnnouncementPage(),
    const AdminMenuPage(),
    const AdminReportsPage(),
  ];

  List drawerPages = [
    const AdminClassroomPage(),
    const AccountPage(),
  ];

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      if (index == 3) {
        scaffoldKey.currentState!.openEndDrawer();
      } else {
        currentIndex = index;
        drawerIndex = -1;
      }
    });
  }

  int drawerIndex = -1;
  void drawer(int index) {
    setState(() {
      drawerIndex = index;
      currentIndex = 3;
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget displayPage() {
    if (drawerIndex != -1) {
      return drawerPages[drawerIndex];
    }
    return pages[currentIndex];
  }

  final user = FirebaseAuth.instance.currentUser!;
  void userLogout() {
    FirebaseAuth.instance.signOut();
  }

  String name = "";
  //fill out profile fields
  Future getName() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    name = documentSnapshot['Name'];
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: userLogout, icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: displayPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          //BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notification_important), label: "Announcements"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More")
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        iconSize: 25,
        unselectedItemColor: Theme.of(context).hintColor,
        selectedItemColor: Colors.black,
        onTap: onTap,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      endDrawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                accountName: Text(
                  name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                accountEmail: Text(
                  user.email!,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: Text(
                  "Manage Classroom",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                onTap: () => drawer(0),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  "Account",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                onTap: () => drawer(1),
              )
            ],
          ),
        ),
      ),
    );
  }
}
