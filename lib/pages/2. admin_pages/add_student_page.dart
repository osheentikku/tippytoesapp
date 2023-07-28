/*import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/add_student_textfield.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  //text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController parentContoller = TextEditingController();

  //load parents
  List<String> allParents = [];
  List<String> allEmails = [];

  List<String> currentParents = [];
  List<String> currentEmails = [];

  @override
  void initState() {
    super.initState();
    loadParents();
  }

  void removeItem(List<String> list, String item) {
    setState(() {
      list.remove(item);
    });
  }

  void saveStudent() {
    addStudentDetails(
        nameController.text.trim().toCapitalCase(), currentParents);

    approveParents(currentParents);
    Navigator.pop(context);
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

  Future loadParents() async {
    try {
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
    } catch (e) {
      print('$e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFECD08),
        elevation: 0,
      ),
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
                  "Add Student",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
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
                decoration: const InputDecoration(
                    labelText: 'Select parent/guardian',
                    labelStyle: TextStyle(color: Colors.black54),
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
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.007),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () => removeItem(list, str),
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
*/