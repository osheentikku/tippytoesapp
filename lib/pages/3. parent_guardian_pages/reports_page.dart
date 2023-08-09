import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  //student name
  String studentName = "";

  //report fields
  String diaperBM = "";
  String diaperWet = "";
  String nap = "";
  String moodAM = "";
  String moodPM = "";
  String health = "";

  bool reportExists = true;

  @override
  void initState() {
    super.initState();
    loadFromFirestore();
  }

  //load student data from Firestore
  Future loadFromFirestore() async {
    //get student from parent document
    User user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot parentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      studentName = parentSnapshot['Student'];
    });

    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayFormat =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';

    //get student data in Firestore
    try {
      //student report for today from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("students")
          .doc(studentName)
          .collection("reports")
          .doc(dateTodayFormat)
          .get();

      if (documentSnapshot.exists) {
        //current student updates
        setState(() {
          diaperBM = documentSnapshot['bm'] ?? "";
          diaperWet = documentSnapshot['wet'] ?? "";
          nap = documentSnapshot['nap'] ?? "";
          moodAM = documentSnapshot['moodAM'] ?? "";
          moodPM = documentSnapshot['moodPM'] ?? "";
          health = documentSnapshot['health'] ?? "";
          reportExists = true;
        });
      } else {
        setState(() {
          diaperBM = "";
          diaperWet = "";
          nap = "";
          moodAM = "";
          moodPM = "";
          health = "";
          reportExists = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget displayText(String report, double padding) {
    if (report.isEmpty) {
      setState(() {
        report = "N/A";
      });
    }
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: padding, vertical: paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: Text(
              report,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget displayReport() {
    if (!reportExists) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Text(
          "The report for today has not been updated.",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  Widget displayDiaper() {
    if (diaperBM.isNotEmpty || diaperWet.isNotEmpty) {
      return Column(
        children: [
          //diaper changes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Diaper Changes:",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
          ),

          //bm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingIndented),
            child: Row(
              children: [
                Text(
                  "Bowel Movements",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
          ),

          displayText(diaperBM, paddingIndented),

          SizedBox(height: paddingMedium),

          //wet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingIndented),
            child: Row(
              children: [
                Text(
                  "Wet",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
          ),
          displayText(diaperWet, paddingIndented),

          SizedBox(
            height: paddingMedium,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double paddingIndented = 0;

  void setPadding(
      double small, double medium, double indent, double horizontal) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      paddingIndented = indent;
      horizontalPadding = horizontal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.1,
        screenWidth * 0.07);
    double dividerThickness = 0.5;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //title
                Text(
                  "$studentName's Report",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                //padding
                SizedBox(
                  height: paddingSmall,
                ),

                Text(
                  //get today's date
                  DateFormat.yMMMEd().format(DateTime.now()),
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                //padding
                SizedBox(
                  height: paddingSmall,
                ),

                //divider
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

                SizedBox(height: paddingSmall),

                displayReport(),

                displayDiaper(),

                //nap
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        "Nap",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                displayText(nap, horizontalPadding),

                SizedBox(
                  height: paddingMedium,
                ),

                //mood AM
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        "Mood AM",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                displayText(moodAM, horizontalPadding),

                SizedBox(
                  height: paddingMedium,
                ),

                //mood pm
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Mood PM",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                displayText(moodPM, horizontalPadding),

                SizedBox(
                  height: paddingMedium,
                ),

                //health
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Health",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                displayText(health, horizontalPadding),

                SizedBox(
                  height: paddingMedium,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
