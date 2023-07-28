import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/add_student_textfield.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  //text controllers
  TextEditingController studentNameController = TextEditingController();
  TextEditingController parentContoller = TextEditingController();

  //load student roster
  List<String> currentStudents = [];
  //load parents
  List<String> allParents = [];
  List<String> allEmails = [];

  List<String> currentParents = [];
  List<String> currentEmails = [];

  @override
  void initState() {
    super.initState();
    loadCurrentStudents();
  }

  Future loadCurrentStudents() async {
    //get students in firestore if doc exists
    QuerySnapshot studentSnapshot =
        await FirebaseFirestore.instance.collection('students').get();

    if (studentSnapshot.size > 0) {
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

    //get all parents
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('Admin', isEqualTo: false)
        .get();

    //reset lists
    allParents.clear();
    allEmails.clear();

    //loop through documents to get parent name/emails
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      String name = docSnapshot['First Name'];
      String email = docSnapshot["Email"];

      allParents.add('$name: $email');
      allEmails.add(email);
    }
  }

  void addParent(String parent) {
    if (parent.isEmpty || currentParents.contains(parent)) {
      return;
    }
    setState(() {
      currentParents.add(parent);
    });

    for (int i = 0; i < allEmails.length; i++) {
      for (int j = 0; j < currentParents.length; j++) {
        if (currentParents[j].contains(allEmails[i])) {
          setState(() {
            currentEmails.add(allEmails[i]);
          });
        }
      }
    }
  }

  void saveStudent(String studentName) {
    addStudentDetails(
        studentNameController.text.trim().toCapitalCase(), currentParents);

    setState(() {
      currentStudents.add(studentName);
    });

    approveParents(currentParents);
  }

  Future approveParents(List<String> currentParents) async {
    try {
      //get current parents docs
      for (String email in currentEmails) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where('Email', isEqualTo: email)
            .get();

        querySnapshot.docs.forEach((doc) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(doc.id)
              .update({'Approved': true});
        });
      }
    } catch (e) {
      print(e);
    }
  }

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
                const Text(
                  "Manage Students",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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

                //current roster
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    children: [
                      Text(
                        'Current Roster',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //display current roster
                bulletedList(currentStudents, screenHeight, screenWidth),

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
                  height: screenHeight * 0.003,
                ),

                //add a new student
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Text(
                    "Add a new student",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                //padding
                SizedBox(height: screenHeight * 0.01),

                //name
                AddStudentTextField(
                  controller: studentNameController,
                  hintText: "Student Name",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

                //parent selector
                bulletedList(currentParents, screenHeight, screenWidth),
                parentSelection(
                    parentContoller, allParents, screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //save button

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
                  child: GestureDetector(
                    onTap: () => saveStudent(
                        studentNameController.text.trim().toCapitalCase()),
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.01),
                      color: const Color(0xffFECD08),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text(
                            "Add a new student",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget parentSelection(TextEditingController controller, List<String> parents,
      double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return parents
                  .where((item) => item.contains(textEditingValue.text))
                  .toList();
            },
            onSelected: (String selectedValue) {
              controller.text = selectedValue;
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              controller = textEditingController;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                    //border
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xffFECD08),
                        width: screenHeight * 0.002,
                      ),
                    ),
                    /*focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xffFECD08),
                        width: screenHeight * 0.002,
                      ),
                    ), */
                    labelText: 'Select parent/guardian',
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54))),
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: Container(
                    //set max height for large lists
                    constraints: BoxConstraints(maxHeight: screenHeight * 0.3),
                    width: screenWidth * 0.7,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.01),

          //add item button
          MaterialButton(
            onPressed: () {
              addParent(controller.text);
              controller.clear();
            },
            color: const Color(0xffFECD08),
            elevation: 1,
            child: const Text(
              'Add Parent',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
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
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.008),
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
