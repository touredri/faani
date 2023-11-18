import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mesure_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> languages = ['Français', 'Anglais'];
  String selectedLanguage = 'Français';
  void openUrl(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          centerTitle: true,
          title: Row(
            children: [
              const Text('      '),
              const Spacer(),
              const Text('Profile'),
              const Spacer(),
              InkWell(
                onTap: () {
                  openUrl('https://www.github.com/touredri/faani');
                },
                child: const Text(
                  'A propos',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: primaryColor, width: 2)),
                        child: const Text('data')),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: primaryColor, width: 2),
                            color: primaryColor),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('John Doe', style: TextStyle(fontSize: 20)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('data'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Text('data'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: primaryColor,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLanguage = newValue!;
                        });
                      },
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: inputBackgroundColor,
                        side:
                            const BorderSide(color: inputBorderColor, width: 1),
                      ),
                      onPressed: () {},
                      child: const Text('Modifier',
                          style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                // go to my measure pages
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MeasurePage()));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.1,
                      right: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Row(
                      children: [
                        const Text('Mes Mésures',
                            style:
                                TextStyle(fontSize: 18, color: primaryColor)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
