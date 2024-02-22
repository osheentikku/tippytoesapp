import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementsDateTextField extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController controller;
  final String hintText;
  final double horizontalPadding;
  final double textfieldBorder;
  final BuildContext context;

  const AnnouncementsDateTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.screenHeight,
    required this.screenWidth,
    required this.horizontalPadding,
    required this.textfieldBorder,
    required this.context,
  });

  @override
  State<AnnouncementsDateTextField> createState() =>
      _AnnouncementsDateTextFieldState();
}

class _AnnouncementsDateTextFieldState
    extends State<AnnouncementsDateTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, widget.horizontalPadding),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2050),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat.yMMMEd().format(pickedDate);
            setState(() {
              widget.controller.text =
                  formattedDate; //set formatted date to TextField value.
            });
          }
        },
        decoration: InputDecoration(
          //border
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: widget.textfieldBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: widget.textfieldBorder,
            ),
          ),

          //hints
          labelText: widget.hintText,
          labelStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
