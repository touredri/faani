import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/style/my_theme.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  DatePickerWidget({required this.onDateSelected});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
          widget.onDateSelected(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 28.0),
        decoration: BoxDecoration(
          border: Border.all(color: inputBorderColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: selectedDate != null
            ? Text(
                DateFormat('yyyy-MM-dd').format(selectedDate!).toString(),
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
              )
            : Text(
                'Date prévue',
                style: TextStyle(color: Colors.black),
              ),
      ),
    );
  }
}
