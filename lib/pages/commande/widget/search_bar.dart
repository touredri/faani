import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';

class CommandeSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const CommandeSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  floatingLabelStyle: TextStyle(
                    color: primaryColor,
                  ),
                  labelText: 'Chercher par nom',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  fillColor: inputBackgroundColor,
                  labelStyle: TextStyle(
                    color: subtextColor,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                ),
    );
  }
}