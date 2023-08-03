import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/show_message.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  //menu controllers
  TextEditingController breakfastController = TextEditingController();
  TextEditingController lunchController = TextEditingController();
  TextEditingController snackController = TextEditingController();

  //options for menu items
  List<String> breakfastOptions = [];
  List<String> lunchOptions = [];
  List<String> snackOptions = [];

  //today's menu items
  List<String> breakfastToday = [];
  List<String> lunchToday = [];
  List<String> snackToday = [];

  @override
  void initState() {
    super.initState();
    loadMealsFromFirestore();
  }

  Future loadMealsFromFirestore() async {
    CollectionReference menuCollection =
        FirebaseFirestore.instance.collection('menus');

    QuerySnapshot querySnapshot = await menuCollection.get();

    Set<String> breakfastSet = <String>{};
    Set<String> lunchSet = <String>{};
    Set<String> snackSet = <String>{};

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      Map<String, dynamic>? mealData =
          docSnapshot.data() as Map<String, dynamic>?;

      List<String> breakfast = List<String>.from(mealData?['breakfast'] ?? []);
      List<String> lunch = List<String>.from(mealData?['lunch'] ?? []);
      List<String> snack = List<String>.from(mealData?['snack'] ?? []);

      breakfastSet.addAll(breakfast);
      lunchSet.addAll(lunch);
      snackSet.addAll(snack);
    }

    setState(() {
      breakfastOptions = breakfastSet.toList();
      lunchOptions = lunchSet.toList();
      snackOptions = snackSet.toList();
    });

    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayString =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';

    //get menu in firestore if doc exists
    DocumentSnapshot menuTodaySnapshot = await FirebaseFirestore.instance
        .collection('menus')
        .doc(dateTodayString)
        .get();

    if (menuTodaySnapshot.exists) {
      setState(() {
        breakfastToday =
            List<String>.from(menuTodaySnapshot['breakfast'] ?? []);
        lunchToday = List<String>.from(menuTodaySnapshot['lunch'] ?? []);
        snackToday = List<String>.from(menuTodaySnapshot['snack'] ?? []);
      });
    } else {
      setState(() {
        breakfastToday = [];
        lunchToday = [];
        snackToday = [];
      });
    }
  }

  void setTodayMenu() {
    //get today's date
    DateTime dateToday = DateTime.now();
    String dateTodayString =
        '${dateToday.month}-${dateToday.day}-${dateToday.year}';

    //set menu in firestore
    FirebaseFirestore.instance.collection('menus').doc(dateTodayString).set({
      'breakfast': breakfastToday,
      'lunch': lunchToday,
      'snack': snackToday,
    }).then((value) {
      // Menu successfully set for today.
      // You can show a confirmation dialog or a snackbar.
      showMessage(context, "Menu successfully updated.");
    }).catchError((e) {
      // Handle errors here.
    });
  }

  void removeItem(List<String> list, String item) {
    setState(() {
      list.remove(item);
    });
  }

  void addMealItem(List<String> list, String mealName, String item) {
    if (item.isEmpty || list.contains(item)) {
      return;
    }
    setState(() {
      list.add(item);
    });
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    breakfastController.dispose();
    lunchController.dispose();
    snackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //Date
                Text(
                  DateFormat.yMMMEd().format(DateTime.now()),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),

                //Padding
                SizedBox(
                  height: screenHeight * 0.01,
                ),

                //today's menu
                const Text(
                  "Today's Menu",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),

                //padding
                SizedBox(
                  height: screenHeight * 0.02,
                ),

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
                  height: screenHeight * 0.02,
                ),

                //breakfast
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    children: [
                      Text(
                        'Breakfast - 9:00 AM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                bulletedList(breakfastToday, screenHeight, screenWidth),
                mealEditor("Breakfast", breakfastController, breakfastOptions,
                    breakfastToday, screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //lunch
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    children: [
                      Text(
                        'Lunch - 11:45 AM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                bulletedList(lunchToday, screenHeight, screenWidth),
                mealEditor("Lunch", lunchController, lunchOptions, lunchToday,
                    screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                //snack
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: const Row(
                    children: [
                      Text(
                        'Snack - 3:00 PM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                bulletedList(snackToday, screenHeight, screenWidth),
                mealEditor("Snack", snackController, snackOptions, snackToday,
                    screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: screenHeight * 0.03,
                ),

                MaterialButton(
                  onPressed: setTodayMenu,
                  color: Theme.of(context).primaryColor,
                  elevation: 1,
                  child: const Text(
                    'Save Menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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

  Widget mealEditor(
      String mealName,
      TextEditingController controller,
      List<String> mealOptions,
      List<String> list,
      double screenHeight,
      double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return mealOptions
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
                    labelText: 'Add Items for $mealName',
                    labelStyle: TextStyle(color: Theme.of(context).hintColor),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).hintColor))),
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
              addMealItem(list, mealName, controller.text);
              controller.clear();
            },
            color: Theme.of(context).primaryColor,
            elevation: 1,
            child: const Text('Add Item'),
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
