import 'package:faani/constants/styles.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/modules/mesures/views/widgets/measure_dialog_box.dart';
import 'package:flutter/material.dart';

class JoinMesureButton extends StatefulWidget {
  final List<Mesure> mesures;
  final Function(String) onMesureSelected;

  JoinMesureButton({required this.mesures, required this.onMesureSelected});

  @override
  _JoinMesureButtonState createState() => _JoinMesureButtonState();
}

class _JoinMesureButtonState extends State<JoinMesureButton> {
  String? selectedMesure = '';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(),
      onPressed: () async {
        selectedMesure = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return MesureDialog(mesures: widget.mesures);
          },
        );
        if (selectedMesure != null) {
          widget.onMesureSelected(selectedMesure!);
          setState(() {
            selectedMesure = selectedMesure;
          });
        }
      },
      child: selectedMesure == ''
          ? Container(
              height: 45,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: inputBorderColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: primaryColor),
                  const SizedBox(width: 5),
                  Text('Mésure', style: TextStyle(color: labelColor)),
                ],
              ),
            )
          : Container(
              height: 45,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: inputBorderColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  selectedMesure!,
                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                ),
              ),
            ),
    );
  }
}
