import 'package:flutter/material.dart';

SizedBox circularProgress() {
  return const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  );
}
