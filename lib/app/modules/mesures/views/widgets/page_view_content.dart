import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spacer/flutter_spacer.dart';

import '../../../../style/my_theme.dart';

class PageViewContent extends StatelessWidget {
  final String text;
  final String imagePath;
  final String count;
  final TextEditingController controller;

  const PageViewContent({
    super.key,
    required this.text,
    required this.imagePath,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Text(count, style: const TextStyle(fontSize: 20, color: primaryColor)),
          4.hs,
          SizedBox(
            // image example
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                )),
          ),
          6.hs,
          Container(
            // name & input measure
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 43,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: controller,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          height: 0.8,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            labelText: 'mésure',
                            counterText: '',
                            prefixIcon: IconButton(
                                onPressed: () {
                                  int currentValue =
                                      int.tryParse(controller.text) ?? 0;
                                  if (currentValue > 0) {
                                    controller.text =
                                        (currentValue - 1).toString();
                                  }
                                },
                                icon: const Icon(Icons.remove)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                int currentValue =
                                    int.tryParse(controller.text) ?? 0;
                                controller.text = (currentValue + 1).toString();
                              },
                              icon: const Icon(Icons.add),
                            )),
                      ),
                    ),
                  ],
                ),
                const Text('Cm'),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
