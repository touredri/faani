import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';

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