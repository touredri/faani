import 'package:flutter/material.dart';
import '../my_theme.dart';

InputDecoration myInputDecoration(String label) {
  return InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black.withOpacity(0.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: inputBorderColor),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: inputBorderColor,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    labelText: label,
  );
}

class MyDropdownButton extends StatefulWidget {
  final String value;
  final ValueChanged<String?>? onChanged;
  final List<String> items;

  MyDropdownButton({required this.value, required this.onChanged, required this.items});

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        border: Border.all(color: inputBorderColor),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          focusColor: inputBackgroundColor,
          dropdownColor: inputBackgroundColor,
          value: widget.value,
          items: widget.items
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

InputDecoration myInputDecorationWithIcon(String label, IconData icon) {
  return InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black.withOpacity(0.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: inputBorderColor),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: inputBorderColor,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    labelText: label,
    prefixIcon: Icon(
      icon,
      color: inputBorderColor,
    ),
  );
}
