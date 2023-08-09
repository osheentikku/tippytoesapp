import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/show_message.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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

  //date
  List<DateTime?> date = [];
  DateTime dateToday = DateTime.now();
  String dateTodayString = "";

  @override
  void initState() {
    super.initState();
    loadMealsFromFirestore();
  }

  Future loadMealsFromFirestore() async {
    setState(() {
      date.add(DateTime.now());
      dateToday = DateTime.now();
      dateTodayString = '${dateToday.month}-${dateToday.day}-${dateToday.year}';
    });

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

  Future changeDate(double screenWidth, double screenHeight) async {
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
      });
    }
    await populateMenu();
  }

  Future populateMenu() async {
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

  //dispose
  @override
  void dispose() {
    super.dispose();
    breakfastController.dispose();
    lunchController.dispose();
    snackController.dispose();
  }

  double paddingSmall = 0;
  double horizontalPadding = 0;
  double paddingMedium = 0;
  double iconSize = 0;

  void setPadding(double small, double medium, double horizontal, double icon) {
    setState(() {
      paddingSmall = small;
      paddingMedium = medium;
      horizontalPadding = horizontal;
      iconSize = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setPadding(
        screenHeight * 0.005, screenHeight * 0.02, screenWidth * 0.07, 25);
    double dividerThickness = 0.5;

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
                  height: paddingMedium,
                ),

                //Date
                GestureDetector(
                  onTap: () => changeDate(screenWidth, screenHeight),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                ),

                //Padding
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

                //breakfast
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        'Breakfast - 9:00 AM',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                bulletedList(breakfastToday, screenHeight, screenWidth),
                mealEditor("Breakfast", breakfastController, breakfastOptions,
                    breakfastToday, screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //lunch
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        'Lunch - 11:45 AM',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                bulletedList(lunchToday, screenHeight, screenWidth),
                mealEditor("Lunch", lunchController, lunchOptions, lunchToday,
                    screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                //snack
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        'Snack - *3:00PM',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        '(*Or when child wakes from nap)',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                bulletedList(snackToday, screenHeight, screenWidth),
                mealEditor("Snack", snackController, snackOptions, snackToday,
                    screenHeight, screenWidth),

                //padding
                SizedBox(
                  height: paddingMedium,
                ),

                MaterialButton(
                  onPressed: setTodayMenu,
                  color: Theme.of(context).primaryColor,
                  elevation: 1,
                  child: Text(
                    'Save Menu',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
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

  Widget mealEditor(
      String mealName,
      TextEditingController controller,
      List<String> mealOptions,
      List<String> mealToday,
      double screenHeight,
      double screenWidth) {
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
                  decoration:
                      InputDecoration(labelText: 'Add item to $mealName'),
                ),
                suggestionsCallback: (String pattern) async {
                  if (pattern.isNotEmpty) {
                    return mealOptions
                        .where((item) =>
                            item.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  }
                  return const Iterable.empty();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  controller.text = suggestion;
                },
                minCharsForSuggestions: 1,
                hideOnEmpty: true,
                autoFlipDirection: true,
              );
            },
          ),
          SizedBox(height: paddingSmall),

          //add item button
          MaterialButton(
            onPressed: () {
              addMealItem(mealToday, mealName, controller.text);
              controller.clear();
            },
            color: Theme.of(context).primaryColor,
            elevation: 1,
            child: Text(
              'Add Item',
              style: Theme.of(context).textTheme.displayMedium,
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
                  onTap: () => removeItem(list, str),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: iconSize,
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
