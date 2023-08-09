import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/report_textfield.dart';

import '../../components/show_message.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  //text controllers
  TextEditingController diaperBMController = TextEditingController();
  TextEditingController diaperWetController = TextEditingController();
  TextEditingController napController = TextEditingController();
  TextEditingController moodAMController = TextEditingController();
  TextEditingController moodPMController = TextEditingController();
  TextEditingController healthController = TextEditingController();

  //load student roster
  List<String> currentStudents = [];
  String currentStudent = "";

  @override
  void initState() {
    super.initState();
    loadFromFirestore();
  }

  //load student data from Firestore
  Future loadFromFirestore() async {
    setState(() {
      currentStudents.clear();
      currentStudents.add("Select a student");
      currentStudent = "Select a student";
    });
    //get all students in Firestore
    QuerySnapshot studentSnapshot =
        await FirebaseFirestore.instance.collection('students').get();

    //if there are students in Firestore
    if (studentSnapshot.size > 0) {
      //Add the students to list of currentStudents
      for (QueryDocumentSnapshot docSnapshot in studentSnapshot.docs) {
        setState(() {
          currentStudents.add(docSnapshot['Name']);
        });
      }
    }
  }

  //populate fields with student data
  Future populateStudent(String studentName) async {
    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayFormat =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';
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
          diaperBMController.text = documentSnapshot['bm'] ?? "";
          diaperWetController.text = documentSnapshot['wet'] ?? "";
          napController.text = documentSnapshot['nap'] ?? "";
          moodAMController.text = documentSnapshot['moodAM'] ?? "";
          moodPMController.text = documentSnapshot['moodPM'] ?? "";
          healthController.text = documentSnapshot['health'] ?? "";
          currentStudent = studentName;
        });
      } else {
        setState(() {
          clearFields();
          currentStudent = studentName;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String displayCurrentStudent() {
    if (currentStudent == "Select a student") {
      return "No student selected";
    } else {
      return "$currentStudent's Report";
    }
  }

  Future saveReport() async {
    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayString =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';

    //set report in firestore
    FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudent)
        .collection("reports")
        .doc(dateTodayString)
        .set({
      'bm': diaperBMController.text.trim(),
      'wet': diaperWetController.text.trim(),
      'nap': napController.text.trim(),
      'moodAM': moodAMController.text.trim(),
      'moodPM': moodPMController.text.trim(),
      'health': healthController.text.trim(),
    }).then((value) {
      // Menu successfully set for today.
      // You can show a confirmation dialog or a snackbar.
      showMessage(context, "Report successfully updated.");
    }).catchError((e) {
      // Handle errors here.
    });
  }

  void clearFields() {
    setState(() {
      diaperBMController.clear();
      diaperWetController.clear();
      napController.clear();
      moodAMController.clear();
      moodPMController.clear();
      healthController.clear();
      currentStudent = "Select a student";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: screenHeight * 0.01,
                ),

                //title
                Text(
                  "Student Reports",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.005,
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

                //padding
                SizedBox(
                  height: screenHeight * 0.005,
                ),

                //display roster in dropdown
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: DropdownButtonFormField(
                    items: currentStudents
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    value: currentStudent,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        currentStudent = newValue;
                        populateStudent(newValue);
                      }
                    },
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //student
                Text(displayCurrentStudent(),
                    style: Theme.of(context).textTheme.displayLarge),

                //divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
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

                //diaper changes
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Diaper Changes",
                        style: Theme.of(context).textTheme.displayLarge,
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
                  child: Row(
                    children: [
                      Text(
                        "Bowel Movements",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),

                //bm textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: ReportTextField(
                      controller: diaperBMController,
                      hintText: "Update Timing",
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),

                //wet
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Row(
                    children: [
                      Text(
                        "Wet",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),

                //wet textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: ReportTextField(
                      controller: diaperWetController,
                      hintText: "Update Timing",
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),

                //nap
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    children: [
                      Text(
                        "Nap",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),

                //nap textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: ReportTextField(
                    controller: napController,
                    hintText: "Update Timing",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ),

                //mood AM
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    children: [
                      Text(
                        "Mood AM",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),

                //moodAM textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: ReportTextField(
                      controller: moodAMController,
                      hintText: "Update Mood",
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),

                //mood pm
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
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

                //mood pm textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: ReportTextField(
                      controller: moodPMController,
                      hintText: "Update Mood",
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),

                //health
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
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

                //health textfield
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: ReportTextField(
                      controller: healthController,
                      hintText: "Update Health",
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),

                //clear and save button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () => clearFields(),
                        padding: EdgeInsets.all(screenHeight * 0.01),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restart_alt_rounded),
                            Text(
                              "Clear",
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.03,
                      ),
                      MaterialButton(
                        onPressed: () => saveReport(),
                        padding: EdgeInsets.all(screenHeight * 0.01),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            Text(
                              "Save Report",
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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

  Widget bulletedListRoster(
      List<String> list, double screenHeight, double screenWidth) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map((str) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.008),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Expanded(
                  child: GestureDetector(
                    onTap: () => populateStudent(str),
                    child: Text(
                      str,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
