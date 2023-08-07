import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Widget displayText(String report, double padding, double screenWidth) {
    if (report.isEmpty) {
      setState(() {
        report = "N/A";
      });
    }
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: padding, vertical: screenWidth * 0.007),
      child: Row(
        children: [
          Expanded(
            child: Text(
              report,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget displayReport(double screenWidth, double screenHeight) {
    if (reportExists) {
      return Column(children: [
        displayDiaper(screenWidth, screenHeight),
        displayMainReport(screenWidth, screenHeight)
      ]);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        child: Text(
          "The report for today has not been updated.",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget displayDiaper(double screenWidth, double screenHeight) {
    if (diaperBM == "N/A" && diaperWet == "N/A") {
      return Column(
        children: [
          //diaper changes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Diaper Changes:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),

          SizedBox(
            height: screenHeight * 0.01,
          ),

          //bm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: const Row(
              children: [
                Text(
                  "Bowel Movements",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),

          displayText(diaperBM, screenWidth * 0.1, screenWidth),

          SizedBox(
            height: screenHeight * 0.02,
          ),

          //wet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: const Row(
              children: [
                Text(
                  "Wet",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
          displayText(diaperWet, screenWidth * 0.1, screenWidth),

          SizedBox(
            height: screenHeight * 0.02,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget displayMainReport(double screenWidth, double screenHeight) {
    return Column(
      children: [
        //nap
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: const Row(
            children: [
              Text(
                "Nap",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        displayText(nap, screenWidth * 0.07, screenWidth),

        SizedBox(
          height: screenHeight * 0.02,
        ),

        //mood AM
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: const Row(
            children: [
              Text(
                "Mood AM",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        displayText(moodAM, screenWidth * 0.07, screenWidth),

        SizedBox(
          height: screenHeight * 0.02,
        ),

        //mood pm
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Mood PM",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        displayText(moodPM, screenWidth * 0.07, screenWidth),

        SizedBox(
          height: screenHeight * 0.02,
        ),

        //health
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Health",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        displayText(health, screenWidth * 0.07, screenWidth),

        SizedBox(
          height: screenHeight * 0.03,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //title
                Text(
                  "$studentName's Report",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.01,
                ),

                //divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.01,
                ),

                displayReport(screenWidth, screenHeight)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
