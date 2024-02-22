import 'dart:collection';

import 'package:change_case/change_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tippytoesapp/components/announcements_date_textfield.dart';
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
  TextEditingController announcementDate = TextEditingController();

  String title = "";
  String body = "";
  String endDate = "";

  List<String> activeAnnouncements = [];
  HashMap<String, String> titleToBody = HashMap();

  @override
  void initState() {
    super.initState();
    loadFromFirestore();
  }

  Future loadFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("announcements")
        .orderBy('End Date')
        .get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      setState(() {
        DateTime endDate = (documentSnapshot["End Date"] as Timestamp).toDate();
        if (endDate
            .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          FirebaseFirestore.instance
              .collection("announcements")
              .doc(documentSnapshot.id)
              .delete();
        } else {
          activeAnnouncements.add(documentSnapshot.id);
          titleToBody[documentSnapshot["Title"]] = documentSnapshot["Body"];
        }
      });
    }
  }

  void newAnnouncement(
      BuildContext context, double screenHeight, double screenWidth) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
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
                AnnouncementsDateTextField(
                    controller: announcementDate,
                    hintText: "End Date",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                    context: context),
                MaterialButton(
                  onPressed: () async {
                    setState(() {
                      title = announcementTitle.text.trim().toCapitalCase();
                      body = announcementBody.text.trim();
                      endDate = announcementDate.text.trim();
                    });
                    if (title.isEmpty) {
                      showMessage(context, "Please enter a title.");
                    } else if (activeAnnouncements.contains(title)) {
                      showMessage(context,
                          "The announcement title already exists. Please rename and try again.");
                    } else if (body.isEmpty) {
                      showMessage(context, "Please enter a body");
                    } else if (endDate.isEmpty) {
                      showMessage(context, "Please enter an end date.");
                    } else {
                      await saveAnnouncement();

                      // Close the bottom sheet
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
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
    //set report in firestore
    FirebaseFirestore.instance.collection('announcements').doc(title).set({
      'Title': title,
      'Body': body,
      'End Date': DateFormat.yMMMEd().parse(endDate),
    }).then((value) {
      // Menu successfully set for today.
      // You can show a confirmation dialog or a snackbar.
      setState(() {
        activeAnnouncements.add(title);
        sortAnnouncements();
        titleToBody[title] = body;
        announcementTitle.clear();
        announcementBody.clear();
        announcementDate.clear();
      });
      showMessage(context, "Announcement successfully created.");
    }).catchError((e) {
      // Handle errors here.
    });
  }

  Future sortAnnouncements() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("announcements")
        .orderBy('End Date')
        .get();

    activeAnnouncements.clear();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      setState(() {
        activeAnnouncements.add(documentSnapshot.id);
      });
    }
  }

  void editAnnouncement(BuildContext context, double screenHeight,
      double screenWidth, String originalTitle) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("announcements")
        .doc(originalTitle)
        .get();
    setState(() {
      announcementTitle.text = originalTitle;
      announcementBody.text = titleToBody[originalTitle]!;
      announcementDate.text =
          DateFormat.yMMMEd().format(documentSnapshot['End Date'].toDate());
    });
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
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
                  'Edit Announcement',
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
                AnnouncementsDateTextField(
                    controller: announcementDate,
                    hintText: "End Date",
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    textfieldBorder: textfieldBorder,
                    context: context),
                MaterialButton(
                  onPressed: () async {
                    setState(() {
                      title = announcementTitle.text.trim().toCapitalCase();
                      body = announcementBody.text.trim();
                      endDate = announcementDate.text.trim();
                    });
                    if (title.isEmpty) {
                      showMessage(context, "Please enter a title.");
                    } else if (title != originalTitle &&
                        activeAnnouncements.contains(title)) {
                      showMessage(context,
                          "The announcement title already exists. Please rename and try again.");
                    } else if (body.isEmpty) {
                      showMessage(context, "Please enter a body");
                    } else if (endDate.isEmpty) {
                      showMessage(context, "Please enter an end date.");
                    } else {
                      await FirebaseFirestore.instance
                          .collection("announcements")
                          .doc(originalTitle)
                          .delete();

                      setState(() {
                        activeAnnouncements.remove(originalTitle);
                      });

                      await saveAnnouncement();

                      // Close the bottom sheet
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
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

  void deleteAnnouncement(String title) async {
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
          content: Text("Are you sure you want to delete $title?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          actionsPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("announcements")
                    .doc(title)
                    .delete();

                setState(() {
                  activeAnnouncements.remove(title);
                });

                if (mounted) {
                  Navigator.of(context).pop();
                  showMessage(context, "$title successfully deleted.");
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

  Widget displayAnnouncements(double screenHeight, double screenWidth) {
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
      return bulletedList(screenHeight, screenWidth);
    }
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

  @override
  void dispose() {
    super.dispose();
    announcementTitle.dispose();
    announcementBody.dispose();
    announcementDate.dispose();
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
                  child: Container(
                    width: screenHeight * 0.75,
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
                ),

                //padding
                SizedBox(
                  height: paddingSmall,
                ),

                //create new announcement
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    width: screenHeight * 0.75,
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
                ),

                SizedBox(height: paddingMedium),
                displayAnnouncements(screenHeight, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }
/*
  Widget bulletedList(double screenHeight, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: activeAnnouncements.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: paddingSmall),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: screenWidth * 0.009,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        titleToBody[item]!,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  } */

  Widget bulletedList(double screenHeight, double screenWidth) {
    return Container(
      width: screenHeight * 0.9,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: activeAnnouncements.length,
        itemBuilder: (context, index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () => editAnnouncement(context, screenHeight,
                        screenWidth, activeAnnouncements[index]),
                    child: Icon(
                      Icons.edit,
                      size: iconSize,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => deleteAnnouncement(activeAnnouncements[index]),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: iconSize,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(paddingSmall),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: textfieldBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        activeAnnouncements[index],
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        titleToBody[activeAnnouncements[index]]!,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

        /*
          return Padding(
            padding: EdgeInsets.symmetric(vertical: paddingSmall),
            child: Container(
              padding: EdgeInsets.all(paddingSmall),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: screenWidth * 0.009,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: paddingSmall,
                  ),
                  Column(
                    children: [
                      Text(
                        item,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        titleToBody[item]!,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );*/