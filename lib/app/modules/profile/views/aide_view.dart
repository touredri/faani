import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AideView extends GetView<ProfileController> {
  AideView({super.key});
  final List<Map<String, dynamic>> questions = [
    {
      'title': 'Comment dévenir Tailleur ?',
      'icon': Icons.person_pin_circle_outlined,
      // 'view': const CommentAcheter(),
    },
    {
      'title': 'Ajouter un modèle à mes favoris ?',
      'icon': Icons.favorite_outline,
      // 'view': const AjoutFavorie(),
    },
    {
      'title': 'Comment Ajouter des modèles ?',
      'icon': Icons.add_circle_outline,
      // 'view': const SignupHelp(),
    },
    {
      'title': 'Comment chercher un tailleur ?',
      'icon': Icons.search_sharp,
      // 'view': const SearchHelp(),
    },
    {
      'title': 'Comment ajouter un moyen de paiement ?',
      'icon': Icons.add_card,
      // 'view': const AjoutCartePayemment(),
    },
  ];

  final RxList<Map<String, dynamic>> filteredQuestions =
      RxList<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar("Centre d'aide"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Rechercher dans l\'aide...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  filterQuestions(value);
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() {
                  return Column(
                    children: filteredQuestions.isEmpty
                        ? questions.map((question) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 45.0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(question['view']);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(question['icon']),
                                        3.ws,
                                        Text(
                                          question['title'],
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                        Icons.keyboard_arrow_right_rounded),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        : filteredQuestions.map((question) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 45.0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(question['view']);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(question['icon']),
                                        3.ws,
                                        Text(
                                          question['title'],
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                        Icons.keyboard_arrow_right_rounded),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                  );
                }),
              ),
            ),
            // const Text(
            //   "Vous ne trouvez pas votre réponse ?",
            // ),
            // 3.hs,
            Container(
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                'Nous contacter',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('+223 93 73 44 81'),
                onTap: () async {
                  final Uri phoneNumber = Uri.parse('tel:+22393734481');
                  if (await canLaunchUrl(phoneNumber)) {
                    await launchUrl(phoneNumber);
                  }
                },
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('touredri223@gmail.com'),
                onTap: () async {
                  final Uri email = Uri.parse('mailto:touredri223@gmail.com');
                  if (await canLaunchUrl(email)) {
                    await launchUrl(email);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterQuestions(String value) {
    filteredQuestions.clear();
    filteredQuestions.addAll(questions.where((question) =>
        question['title'].toLowerCase().contains(value.toLowerCase())));
  }
}
