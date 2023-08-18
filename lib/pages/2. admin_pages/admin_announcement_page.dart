import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/announcements_textfield.dart';

import '../../components/show_message.dart';

class AdminAnnouncementPage extends StatefulWidget {
  const AdminAnnouncementPage({super.key});

  @override
  State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  TextEditingController announcementTitle = TextEditingController();
  TextEditingController announcementBody = TextEditingController();

  String title = "";
  String body = "";

  List<String> activeAnnouncements = [];

  @override
  void initState() {
    super.initState();
    loadFromFirestore();
  }

  Future loadFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("announcements")
        .orderBy('Created', descending: true)
        .get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      setState(() {
        activeAnnouncements.add(documentSnapshot.id);
      });
    }
    if (activeAnnouncements.isNotEmpty) {
      populateAnnouncement(activeAnnouncements[0]);
    }
  }

  void newAnnouncement(
      BuildContext context, double screenHeight, double screenWidth) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled:
          false, // Optional: Set to true if you want a full-screen sheet
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: paddingMedium,
                ),
                Text(
                  'Create Announcement',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                SizedBox(height: paddingSmall * 3),
                AnnouncementsTextField(
                  controller: announcementTitle,
                  hintText: "Title",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                  textfieldBorder: textfieldBorder,
                ),
                AnnouncementsTextField(
                  controller: announcementBody,
                  hintText: "Body",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  horizontalPadding: horizontalPadding,
                  textfieldBorder: textfieldBorder,
                ),
                MaterialButton(
                  onPressed: () async {
                    setState(() {
                      title = announcementTitle.text.trim().toCapitalCase();
                      body = announcementBody.text.trim();
                    });
                    if (activeAnnouncements.contains(title)) {
                      showMessage(context,
                          "The announcement title already exists. Please rename and try again.");
                    } else {
                      await saveAnnouncement();
                    }

                    // Close the bottom sheet
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Post Announcement',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                SizedBox(
                  height: paddingMedium,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future saveAnnouncement() async {
    if (title.isEmpty) {
      showMessage(context, "Please enter a title.");
    } else {
      //set report in firestore
      FirebaseFirestore.instance.collection('announcements').doc(title).set({
        'Title': title,
        'Body': body,
        'Created': FieldValue.serverTimestamp()
      }).then((value) {
        // Menu successfully set for today.
        // You can show a confirmation dialog or a snackbar.
        setState(() {
          activeAnnouncements.insert(0, title);
        });
        showMessage(context, "Announcement successfully created.");
      }).catchError((e) {
        // Handle errors here.
      });
    }
  }

  void deleteAnnouncement(String str) async {
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
          content: Text("Are you sure you want to delete $str?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () async {
                int colonPosition = str.indexOf(":");
                String documentName = str.substring(0, colonPosition - 1);

                await FirebaseFirestore.instance
                    .collection("announcements")
                    .doc(documentName)
                    .delete();

                if (mounted) {
                  Navigator.of(context).pop();
                  showMessage(context, "$str successfully deleted.");
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

  Widget displayAnnouncements(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: screenWidth * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Column(),
            ),
          ),
          Expanded(
            child: Container(
              width: screenWidth * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Column(),
            ),
          ),
        ],
      ),
    );
    if (activeAnnouncements.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Text(
          "There are no recent announcements.",
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return displayMainAnnouncement();
    }
    //displayOtherAnnouncements();
    //return Container();
  }

  Widget displayMainAnnouncement() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: paddingSmall),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: paddingSmall),
                        Visibility(
                          visible: body.isNotEmpty,
                          child: Text(
                            body,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future populateAnnouncement(String announcement) async {
    DocumentSnapshot main = await FirebaseFirestore.instance
        .collection("announcements")
        .doc(announcement)
        .get();
    setState(() {
      title = main["Title"] ?? "";
      body = main["Body"] ?? "";
    });
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double iconSize = 0;
  double textfieldBorder = 0;

  void setPadding(double small, double medium, double horizontal, double icon,
      double border) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
      iconSize = icon;
      textfieldBorder = border;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.07,
        25, screenHeight * 0.003);
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
                  "Announcements",
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

                //create new announcement
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: MaterialButton(
                    onPressed: () =>
                        newAnnouncement(context, screenHeight, screenWidth),
                    padding: EdgeInsets.all(paddingSmall),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add),
                        Text(
                          "New Announcement",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: paddingMedium),
                displayAnnouncements(screenWidth),
              ],
            ),
          ),
        ),
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
                  child: Text(
                    str,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () => deleteAnnouncement(str),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: iconSize,
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
