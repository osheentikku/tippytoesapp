import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  //date
  List<DateTime?> date = [];
  DateTime dateToday = DateTime.now();
  String dateTodayString = "";

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
      date.add(DateTime.now());
      dateToday = DateTime.now();
      dateTodayString = '${dateToday.month}-${dateToday.day}-${dateToday.year}';
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
    String dateTodayFormat =
        '${date[0]!.month}-${date[0]!.day}-${date[0]!.year}';
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
    String dateTodayString =
        '${date[0]!.month}-${date[0]!.day}-${date[0]!.year}';

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

  Future changeDate(
      double screenWidth, double screenHeight, String studentName) async {
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: DateTime.now().subtract(const Duration(days: 7)),
        lastDate: DateTime.now().add(const Duration(days: 7)),
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
        diaperBMController.clear();
        diaperWetController.clear();
        napController.clear();
        moodAMController.clear();
        moodPMController.clear();
        healthController.clear();
      });
    }
    populateStudent(studentName);
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

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double paddingIndented = 0;
  double iconSize = 0;

  void setPadding(double small, double medium, double indent, double horizontal,
      double icon) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      paddingIndented = indent;
      horizontalPadding = horizontal;
      iconSize = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.1,
        screenWidth * 0.07, 25);
    double dividerThickness = 0.5;
    double textfieldBorder = screenHeight * 0.003;
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
            child: Container(
              width: screenHeight * 0.75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //padding
                  SizedBox(
                    height: paddingMedium,
                  ),

                  //title
                  Container(
                    width: screenHeight * 0.75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Student Reports | ",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        //Date
                        GestureDetector(
                          onTap: () => changeDate(
                              screenWidth, screenHeight, currentStudent),
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
                      ],
                    ),
                  ),

                  //padding
                  SizedBox(
                    height: paddingSmall,
                  ),

                  //divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: dividerThickness,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),

                  //padding
                  SizedBox(
                    height: paddingSmall,
                  ),

                  //display roster in dropdown
                  DropdownButtonFormField(
                    items: currentStudents
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
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

                  SizedBox(
                    height: paddingMedium,
                  ),

                  //student
                  Text(displayCurrentStudent(),
                      style: Theme.of(context).textTheme.displayLarge),

                  //divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: dividerThickness,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: paddingSmall,
                  ),

                  //bm
                  Row(
                    children: [
                      Text(
                        "Diaper Change - Bowel Movements",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //bm textfield
                  ReportTextField(
                    controller: diaperBMController,
                    hintText: "Update Timing",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //wet
                  Row(
                    children: [
                      Text(
                        "Diaper Change - Wet",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //wet textfield
                  ReportTextField(
                    controller: diaperWetController,
                    hintText: "Update Timing",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //nap
                  Row(
                    children: [
                      Text(
                        "Nap",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //nap textfield
                  ReportTextField(
                    controller: napController,
                    hintText: "Update Timing",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //mood AM
                  Row(
                    children: [
                      Text(
                        "Mood AM",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //moodAM textfield
                  ReportTextField(
                    controller: moodAMController,
                    hintText: "Update Mood",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //mood pm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Mood PM",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //mood pm textfield
                  ReportTextField(
                    controller: moodPMController,
                    hintText: "Update Mood",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //health
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Health",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  //health textfield
                  ReportTextField(
                    controller: healthController,
                    hintText: "Update Health",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                  ),

                  //clear and save button
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () => clearFields(),
                          padding: EdgeInsets.all(paddingMedium),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restart_alt_rounded),
                              Text(
                                "Clear",
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: paddingMedium,
                        ),
                        MaterialButton(
                          onPressed: () => saveReport(),
                          padding: EdgeInsets.all(paddingMedium),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add),
                              Text(
                                "Save Report",
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: paddingMedium,
                  )
                ],
              ),
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
                SizedBox(height: paddingMedium),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
