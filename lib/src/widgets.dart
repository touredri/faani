import 'package:flutter/material.dart';
import '../modele/modele.dart';
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

  MyDropdownButton(
      {required this.value, required this.onChanged, required this.items});

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
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
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

Container _myFilterContainer(String label, VoidCallback onPressed) {
  return Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    // margin: const EdgeInsets.only(top: 5),
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFA4CEFB)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w300,
              height: 0,
            ),
          ),
        ),
      ],
    ),
  );
}

TextButton myFilterContainer(String label, onPressed, String currentFilter) {
  bool v = currentFilter == label;
  return TextButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        decoration: ShapeDecoration(
          color: v ? primaryColor : null,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFA4CEFB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: v ? Colors.white : Colors.black,
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ),
      ));
}

Stack homeItem(Modele modele) {
  return Stack(
    children: [
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: modele.fichier.length,
              itemBuilder: (context, imageIndex) {
                return Image.network(
                  modele.fichier[imageIndex]!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
      Positioned(
        right: 0,
        bottom: 0,
        top: 0,
        // height: 130,
        child: Container(
          height: 130,
          width: 100,
          // alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Colors.white.withOpacity(0.8),
          ),
          child: Column(
            children: [
              Text(
                'Bazin',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
