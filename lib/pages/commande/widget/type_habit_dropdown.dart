import 'package:faani/app_state.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCategory extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;

  const SelectCategory({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  SelectCategoryState createState() => SelectCategoryState();
}

class SelectCategoryState extends State<SelectCategory> {
  late String selectedCategoryId;
  late List<Categorie> categories;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = '';
    categories =
        Provider.of<ApplicationState>(context, listen: false).categorie;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
          labelText: 'Type habit', labelStyle: TextStyle(color: Colors.black)),
      value: selectedCategoryId.isEmpty ? null : selectedCategoryId,
      items: categories.map((categorie) {
        return DropdownMenuItem<String>(
          value: categorie.id,
          child: Text(
            categorie.libelle,
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategoryId = value ?? "";
        });
        widget.onCategorySelected(selectedCategoryId);
      },
    );
  }
}
