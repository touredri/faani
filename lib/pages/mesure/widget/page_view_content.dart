import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageViewContent extends StatelessWidget {
  final String text;
  final String imagePath;
  final String count;
  final TextEditingController controller;
  final Function onChanged;
  
  PageViewContent({
    required this.text,
    required this.imagePath,
    required this.controller,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text(count, style: TextStyle(fontSize: 20, color: primaryColor)),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              )),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 207,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        if (currentValue > 0) {
                          controller.text = (currentValue - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {},
                        maxLength: 3,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'mésure',
                          labelStyle: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentValue = int.tryParse(controller.text) ?? 0;
                        controller.text = (currentValue + 1).toString();
                      },
                    ),
                  ],
                ),
              ),
              const Text('Cm'),
            ],
          ),
        ),
      ]),
    );
  }
}