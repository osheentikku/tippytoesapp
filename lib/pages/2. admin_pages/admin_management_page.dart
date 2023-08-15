import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../components/add_student_textfield.dart';
import '../../components/show_message.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  //text controllers
  TextEditingController studentNameController = TextEditingController();
  TextEditingController parentContoller = TextEditingController();
  TextEditingController staffContoller = TextEditingController();

  //load student roster
  List<String> currentStudents = [];
  //load parents
  List<String> allParents = [];
  List<String> currentParents = [];
  List<String> currentParentEmails = [];

  //currentStaff
  List<String> allStaff = [];
  List<String> currentStaff = [];

  //edit/add mode
  bool isNew = true;

  @override
  void initState() {
    super.initState();
    loadFromFirestore();
  }

  //load student, parent, and staff data from Firestore
  Future loadFromFirestore() async {
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
    } else {
      setState(() {
        currentStudents = [];
      });
    }

    //get all parents in Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('Admin', isEqualTo: false)
        .get();

    //reset lists
    allParents.clear();
    currentParentEmails.clear();
    currentParents.clear();

    //loop through documents to get parent name/emails
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      String name = docSnapshot['Name'];
      String email = docSnapshot["Email"];

      allParents.add('$name: $email');
    }

    //get all staff in Firestore
    QuerySnapshot staffSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('Admin', isEqualTo: true)
        .get();

    //reset lists
    currentStaff.clear();

    //loop through documents to get staff name/emails
    for (QueryDocumentSnapshot docSnapshot in staffSnapshot.docs) {
      String name = docSnapshot['Name'];
      String email = docSnapshot["Email"];

      allStaff.add('$name: $email');
    }
  }

  //set edit/add student mode
  String editOrAddStudent() {
    if (isNew) {
      return "Add a new student";
    } else {
      return "Edit existing student.";
    }
  }

  //populate fields with student data
  Future populateStudent(String studentName) async {
    //edit mode
    isNew = false;

    //set student name
    studentNameController.text = studentName;

    //get student document w/ parent information
    try {
      //student document from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where("Name", isEqualTo: studentName)
          .get();

      //update student
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        setState(() {
          currentParents =
              List<String>.from(docSnapshot["ParentOrGuardian"] ?? []);
        });
      }

      for (String parent in currentParents) {
        int colonPosition = parent.indexOf(":");
        String email = parent.substring(colonPosition + 2);
        email = email.trim();
        setState(() {
          currentParentEmails.add(email);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //save student data to Firestore
  void saveStudent(String studentName) async {
    //check if student already exists
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("students")
        .where('Name', isEqualTo: studentName)
        .get();

    //fields need to be filled
    if (studentNameController.text.trim().isEmpty || currentParents.isEmpty) {
      if (mounted) {
        showMessage(context, "Please fill out all fields.");
      }
    } else {
      //if student exists, remove their data
      if (querySnapshot.docs.isNotEmpty) {
        //unapprove its parents
        await unapproveParents(studentName);

        //delete document
        await FirebaseFirestore.instance
            .collection("students")
            .doc(studentName)
            .delete();

        //remove from current students
        setState(() {
          currentStudents.remove(studentName);
        });
      }

      //add student to firestore
      addStudentDetails(
          studentNameController.text.trim().toCapitalCase(), currentParents);

      //add new student to roster of current students
      setState(() {
        currentStudents.add(studentName);
      });

      //approve student's parents
      await approveParents(currentParents);

      //add student to parents doc
      await connectStudent(studentName);

      //clear "add a new student" fields
      clearFields();

      isNew = true;
    }
  }

  //remove student from given list
  void removeStudent(List<String> list, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          title: Center(
            child: Text("Confirmation",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          content: Text("Are you sure you want to delete $item?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () async {
                //unapprove parents
                await unapproveParents(item);

                //delete document
                await FirebaseFirestore.instance
                    .collection("students")
                    .doc(item)
                    .delete();

                //remove from current students
                setState(() {
                  list.remove(item);
                });

                if (mounted) {
                  Navigator.of(context).pop();
                  showMessage(context, "$item successfully deleted.");
                }
              },
              child: const Text(
                "Yes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "No",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        );
      },
    );
  }

  //add student data to database
  Future addStudentDetails(
      String studentName, List<String> currentParents) async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(studentName)
        .set({
      'Name': studentName,
      'ParentOrGuardian': currentParents,
    });
  }

  //add parent for new student
  void addParent(String parent) {
    //check if parent is empty or has already been added
    if (parent.isEmpty || currentParents.contains(parent)) {
      return;
    }

    //update currentParents
    setState(() {
      currentParents.add(parent);
    });

    //add parent's email to current emails
    int colonPosition = parent.indexOf(":");
    String email = parent.substring(colonPosition + 2);
    email = email.trim();
    setState(() {
      currentParentEmails.add(email);
    });
  }

  //remove parent from current lists
  void removeParent(String parent) {
    int colonPosition = parent.indexOf(":");
    String email = parent.substring(colonPosition + 2);
    email = email.trim();

    setState(() {
      currentParents.remove(parent);
      currentParentEmails.remove(email);
    });
  }

  //approve all parents in currentParents list
  Future approveParents(List<String> currentParents) async {
    try {
      //get current parents docs
      for (String email in currentParentEmails) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where('Email', isEqualTo: email)
            .get();

        //approve current parents
        for (DocumentSnapshot doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.id)
              .update({'Approved': true});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //unapprove parents associated with given studentName
  Future unapproveParents(String studentName) async {
    try {
      //get student's parents
      List<String> parentsToUnapprove = [];
      List<String> parentEmails = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where("Name", isEqualTo: studentName)
          .get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        parentsToUnapprove =
            List<String>.from(docSnapshot["ParentOrGuardian"] ?? []);
      }

      for (String parent in parentsToUnapprove) {
        int colonPosition = parent.indexOf(":");
        String email = parent.substring(colonPosition + 2);
        email = email.trim();
        setState(() {
          parentEmails.add(email);
        });
      }

      //get current parents docs
      for (String email in parentEmails) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where('Email', isEqualTo: email)
            .get();

        //unapprove current parents
        for (DocumentSnapshot doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.id)
              .update({'Approved': false});
          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.id)
              .update({'Student': null});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //add student to parents

  Future connectStudent(String studentName) async {
    try {
      //get current parents docs
      for (String email in currentParentEmails) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where('Email', isEqualTo: email)
            .get();

        //approve current parents
        for (DocumentSnapshot doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.id)
              .update({'Student': studentName});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //add staff to current list
  void addStaff(String staff) {
    //check if staff is empty or has already been added
    if (staff.isEmpty || currentStaff.contains(staff)) {
      return;
    }

    //update currentStaff
    setState(() {
      currentStaff.add(staff);
    });

    approveStaff(staff);
  }

  //remove given staff
  void removeStaff(String staff) async {
    int colonPosition = staff.indexOf(":");
    String email = staff.substring(colonPosition + 2);
    email = email.trim();

    setState(() {
      currentStaff.remove(staff);
    });

    try {
      //get current staff docs
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('Email', isEqualTo: email)
          .get();

      //approve staff
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(doc.id)
            .update({'Approved': false});
      }
    } catch (e) {
      print(e);
    }
  }

  //approve given staff member
  Future approveStaff(String staff) async {
    int colonPosition = staff.indexOf(":");
    String email = staff.substring(colonPosition + 2);
    email = email.trim();

    try {
      //get current staff docs
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('Email', isEqualTo: email)
          .get();

      //approve staff
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(doc.id)
            .update({'Approved': true});
      }
    } catch (e) {
      print(e);
    }
  }

  //clear fiekds
  void clearFields() {
    setState(() {
      studentNameController.clear();
      currentParents.clear();
      currentParentEmails.clear();
      parentContoller.clear();
      staffContoller.clear();
      isNew = true;
    });
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    studentNameController.dispose();
    parentContoller.dispose();
    staffContoller.dispose();
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double deleteSize = 0;
  void setPadding(
      double small, double medium, double horizontal, double deleteIcon) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
      deleteSize = deleteIcon;
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
                  "Manage Students",
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

                //padding
                SizedBox(
                  height: paddingSmall,
                ),

                //current roster
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text('Current Roster',
                          style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                ),

                //padding
                SizedBox(
                  height: paddingSmall,
                ),

                //display current roster
                bulletedListRoster(currentStudents),

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

                SizedBox(
                  height: paddingSmall,
                ),

                //add/edit a new student
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    editOrAddStudent(),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                //padding
                SizedBox(height: paddingSmall),

                //student name
                AddStudentTextField(
                  controller: studentNameController,
                  hintText: "Student Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                ),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //parent selector
                bulletedListParent(currentParents),
                SizedBox(
                  height: paddingSmall,
                ),
                parentSelection(
                  parentContoller,
                  allParents,
                ),

                //padding
                SizedBox(height: paddingMedium),

                //clear and save button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () => clearFields(),
                        padding: EdgeInsets.all(paddingSmall),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restart_alt_rounded),
                            Text(
                              "Clear",
                              style: Theme.of(context).textTheme.displayMedium,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: paddingMedium,
                      ),
                      MaterialButton(
                        onPressed: () => saveStudent(
                            studentNameController.text.trim().toCapitalCase()),
                        padding: EdgeInsets.all(paddingSmall),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            Text(
                              "Save student",
                              style: Theme.of(context).textTheme.displayMedium,
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

                SizedBox(
                  height: paddingSmall,
                ),

                //title
                Text(
                  "Manage Staff",
                  style: Theme.of(context).textTheme.displayLarge,
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

                //Add Staff
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    "Add Staff",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                //padding
                SizedBox(height: paddingSmall),

                //staff selector
                bulletedListStaff(currentStaff),
                SizedBox(
                  height: paddingSmall,
                ),
                staffSelection(staffContoller, allStaff),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget parentSelection(
      TextEditingController controller, List<String> parents) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Select Parent/Guardian',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                suggestionsCallback: (String pattern) async {
                  return parents
                      .where((item) =>
                          item.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  controller.text = suggestion;
                },
                hideOnEmpty: true,
                autoFlipDirection: true,
              );
            },
          ),
          SizedBox(height: paddingSmall),

          //add item button
          MaterialButton(
            onPressed: () {
              addParent(controller.text);
              controller.clear();
            },
            color: Theme.of(context).primaryColor,
            elevation: 1,
            child: Text(
              'Add Parent',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget staffSelection(TextEditingController controller, List<String> staff) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Select Staff',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                suggestionsCallback: (String pattern) async {
                  return staff
                      .where((item) =>
                          item.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  controller.text = suggestion;
                },
                hideOnEmpty: true,
                autoFlipDirection: true,
              );
            },
          ),
          SizedBox(height: paddingSmall),

          //add item button
          MaterialButton(
            onPressed: () {
              addStaff(controller.text);
              controller.clear();
            },
            color: Theme.of(context).primaryColor,
            elevation: 1,
            child: Text(
              'Add Staff',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget bulletedListRoster(List<String> list) {
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
                Expanded(
                  child: GestureDetector(
                    onTap: () => populateStudent(str),
                    child: Text(
                      str,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => removeStudent(list, str),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: deleteSize,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bulletedListParent(List<String> list) {
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
                GestureDetector(
                  onTap: () => removeParent(str),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: deleteSize,
                  ),
                ),
                SizedBox(
                  width: paddingSmall,
                ),
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

  Widget bulletedListStaff(List<String> list) {
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
                GestureDetector(
                  onTap: () => removeStaff(str),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: deleteSize,
                  ),
                ),
                SizedBox(
                  width: paddingSmall,
                ),
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
