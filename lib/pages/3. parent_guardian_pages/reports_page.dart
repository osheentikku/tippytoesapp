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
          diaperBM = documentSnapshot['bm'] ?? "N/A";
          diaperWet = documentSnapshot['wet'] ?? "N/A";
          nap = documentSnapshot['nap'] ?? "";
          moodAM = documentSnapshot['moodAM'] ?? "N/A";
          moodPM = documentSnapshot['moodPM'] ?? "N/A";
          health = documentSnapshot['health'] ?? "N/A";
        });
      } else {
        setState(() {
          diaperBM = "The report for today has not been updated.";
          diaperWet = "The report for today has not been updated.";
          nap = "The report for today has not been updated.";
          moodAM = "The report for today has not been updated.";
          moodPM = "The report for today has not been updated.";
          health = "The report for today has not been updated.";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget displayText(String report, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.004,
                ),

                //divider
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

                SizedBox(
                  height: screenHeight * 0.004,
                ),

                //diaper changes
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Diaper Changes:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),

                displayText(diaperBM, screenWidth * 0.1),

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                displayText(diaperWet, screenWidth * 0.1),

                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //nap
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    children: [
                      Text(
                        "Nap",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                displayText(nap, screenWidth * 0.07),

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                displayText(moodAM, screenWidth * 0.07),

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                displayText(moodPM, screenWidth * 0.07),

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                displayText(health, screenWidth * 0.07),

                SizedBox(
                  height: screenHeight * 0.03,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
