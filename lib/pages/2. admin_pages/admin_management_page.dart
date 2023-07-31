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
  final TextEditingController parentContoller = TextEditingController();

  //load student roster
  List<String> currentStudents = [];
  //load parents
  List<String> allParents = [];
  List<String> allEmails = [];

  //edit current student info
  List<String> currentParents = [];
  List<String> currentEmails = [];

  //edit/add mode
  bool isNew = true;

  @override
  void initState() {
    super.initState();
    loadCurrentStudents();
  }

  //load student and parent data from Firestore
  Future loadCurrentStudents() async {
    //get all students in Firestore
    QuerySnapshot studentSnapshot =
        await FirebaseFirestore.instance.collection('students').get();

    //if there are students in Firestore
    if (studentSnapshot.size > 0) {
      //Add student to list of currentStudents
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
    currentEmails.clear();
    currentParents.clear();

    //loop through documents to get parent name/emails
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      String name = docSnapshot['First Name'] + " " + docSnapshot['Last Name'];
      String email = docSnapshot["Email"];

      allParents.add('$name: $email');
    }
  }

  String editOrAddStudent() {
    if (isNew) {
      return "Add a new student";
    } else {
      return "Edit existing student.";
    }
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
      currentEmails.add(email);
    });
  }

  //remove item from given list
  void removeParent(String parent) {
    int colonPosition = parent.indexOf(":");
    String email = parent.substring(colonPosition + 2);
    email = email.trim();

    setState(() {
      currentParents.remove(parent);
      currentEmails.remove(email);
    });
  }

  void clearFields() {
    setState(() {
      studentNameController.clear();
      currentParents.clear();
      currentEmails.clear();
    });
  }

  //remove student from given list
  void removeStudent(List<String> list, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              "Confirmation",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 107, 95, 95),
              ),
            ),
          ),
          content: Text(
            "Are you sure you want to delete $item",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 107, 95, 95),
            ),
          ),
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
                }
                showMessage("$item successfully deleted.");
              },
              child: const Text("Yes"),
            ),
            TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("No"))
          ],
        );
      },
    );
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
      showMessage("Please fill out all fields.");
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

      //clear "add a new student" fields
      clearFields();
    }
  }

  Future approveParents(List<String> currentParents) async {
    try {
      //get current parents docs
      for (String email in currentEmails) {
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
        }
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

  Future populateStudent(String studentName) async {
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
          currentEmails.add(email);
        });
      }
    } catch (e) {
      print(e);
    }
  }

//message popup
  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 107, 95, 95),
              ),
            ),
          ),
        );
      },
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
                bulletedListRoster(currentStudents, screenHeight, screenWidth),

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

                //add/edit a new student
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Text(
                    editOrAddStudent(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                //padding
                SizedBox(height: screenHeight * 0.02),

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
                bulletedListParent(currentParents, screenHeight, screenWidth),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                parentSelection(
                    parentContoller, allParents, screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //clear and save button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => clearFields(),
                        child: Container(
                          padding: EdgeInsets.all(screenHeight * 0.01),
                          color: const Color(0xffFECD08),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restart_alt_rounded),
                              Text(
                                "Clear",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.03,
                      ),
                      GestureDetector(
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
                                "Save student",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  labelText: 'Select parent/guardian',
                  labelStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                ),
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
                GestureDetector(
                  onTap: () => removeStudent(list, str),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 25,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bulletedListParent(
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
                GestureDetector(
                  onTap: () => removeParent(str),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 25,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.005,
                ),
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
