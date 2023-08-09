import 'package:calendar_date_picker2/calendar_date_picker2.dart';
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

  //date
  List<DateTime?> date = [];
  DateTime dateToday = DateTime.now();
  String dateTodayString = "";

  @override
  void initState() {
    super.initState();
    loadMealsFromFirestore();
  }

  Future loadMealsFromFirestore() async {
    setState(() {
      date.add(DateTime.now());
      dateToday = DateTime.now();
      dateTodayString = '${dateToday.month}-${dateToday.day}-${dateToday.year}';
    });

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
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: paddingMedium),
              Expanded(
                child: Text(
                  "Oops! The menu will be updated soon.",
                  textAlign: TextAlign.left,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium,
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

  Future populateMenu() async {
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

  Future changeDate(double screenWidth, double screenHeight) async {
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: DateTime.now().subtract(const Duration(days: 7)),
        lastDate: DateTime.now().add(const Duration(days: 1)),
      ),
      dialogSize: Size(screenWidth * 0.8, screenHeight * 0.2),
      borderRadius: BorderRadius.circular(15),
      value: date,
      dialogBackgroundColor: Colors.white,
    );
    if (values != null) {
      setState(() {
        date = values;
        dateTodayString = '${date[0]!.month}-${date[0]!.day}-${date[0]!.year}';
      });
    }
    await populateMenu();
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double iconSize = 0;

  void setPadding(double small, double medium, double horizontal, double icon) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
      iconSize = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(
        screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.07, 25);
    double dividerThickness = 0.5;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //padding
              SizedBox(
                height: paddingMedium,
              ),

              //Date
              GestureDetector(
                onTap: () => changeDate(screenWidth, screenHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: iconSize,
                      ),
                      Text(
                        DateFormat.yMMMEd().format(date[0]!),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
              ),

              //padding
              SizedBox(
                height: paddingSmall,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: dividerThickness,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
              ),

              //padding
              SizedBox(
                height: paddingSmall,
              ),

              //breakfast
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      'Breakfast - 9:00 AM',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
              displayText(breakfastToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: paddingMedium,
              ),

              //lunch
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      'Lunch - 11:45 AM',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
              displayText(lunchToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: paddingMedium,
              ),

              //snack
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      'Snack - *3:00 PM',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      '(*Or when child wakes from nap)',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
              displayText(snackToday, screenHeight, screenWidth),

              //padding
              SizedBox(
                height: paddingMedium,
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map((str) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: paddingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: paddingMedium),
                Expanded(
                  child: Text(
                    str,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium,
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
