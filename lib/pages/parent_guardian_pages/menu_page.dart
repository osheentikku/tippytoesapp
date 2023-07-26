import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  //today's menu items
  List<String> breakfastToday = [];
  List<String> lunchToday = [];
  List<String> snackToday = [];

  @override
  void initState() {
    super.initState();
    loadMealsFromFirestore();
  }

  Future loadMealsFromFirestore() async {
    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayString =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';

    //get menu in firestore if doc exists
    DocumentSnapshot menuTodaySnapshot = await FirebaseFirestore.instance
        .collection('menus')
        .doc(dateTodayString)
        .get();

    if (menuTodaySnapshot.exists) {
      setState(() {
        breakfastToday =
            List<String>.from(menuTodaySnapshot['breakfast'] ?? []);
        lunchToday = List<String>.from(menuTodaySnapshot['lunch'] ?? []);
        snackToday = List<String>.from(menuTodaySnapshot['snack'] ?? []);
      });
    } else {
      setState(() {
        breakfastToday = [];
        lunchToday = [];
        snackToday = [];
      });
    }
  }

  Widget displayText(
      List<String> list, double screenHeight, double screenWidth) {
    if (list.isEmpty) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.007),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              const Expanded(
                child: Text(
                  "The menu for today has not been set.",
                  textAlign: TextAlign.left,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return bulletedList(list, screenHeight, screenWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //padding
              SizedBox(
                height: screenHeight * 0.03,
              ),

              //Date
              Text(
                DateFormat.yMMMEd().format(DateTime.now()),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),

              //Padding
              SizedBox(
                height: screenHeight * 0.01,
              ),

              //today's menu
              const Text(
                "Today's Menu",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

              //padding
              SizedBox(
                height: screenHeight * 0.02,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(255, 116, 97, 97),
                      ),
                    ),
                  ],
                ),
              ),

              //padding
              SizedBox(
                height: screenHeight * 0.02,
              ),

              //breakfast
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: const Row(
                  children: [
                    Text(
                      'Breakfast - 9:00 AM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              displayText(breakfastToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: screenHeight * 0.03,
              ),

              //lunch
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: const Row(
                  children: [
                    Text(
                      'Lunch - 11:45 AM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              displayText(lunchToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: screenHeight * 0.03,
              ),

              //snack
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: const Row(
                  children: [
                    Text(
                      'Snack - 3:00 PM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              displayText(snackToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: screenHeight * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bulletedList(
      List<String> list, double screenHeight, double screenWidth) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map((str) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.007),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Expanded(
                  child: Text(
                    str,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
