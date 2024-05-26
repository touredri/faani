import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

Future commentaire(BuildContext context) {
  return showFloatingModalBottomSheet(
      context: context,
      horizontalPadding: 5,
      builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 525,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(),
                      const Text(
                        "🤩",
                        style: TextStyle(fontSize: 55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: primaryColor,
                      ),
                    ],
                  ),
                  const Text(
                    "How like will you you recommand Fanni to a friend?",
                    textAlign: TextAlign.center,
                  ),
                  1.hs,
                  RatingBar.builder(
                    initialRating: 3,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return const Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                        case 1:
                          return const Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.redAccent,
                          );
                        case 2:
                          return const Icon(
                            Icons.sentiment_neutral,
                            color: Colors.amber,
                          );
                        case 3:
                          return const Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.lightGreen,
                          );
                        case 4:
                          return const Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                        default:
                          return const Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                      }
                    },
                    onRatingUpdate: (rating) {
                      // print(rating);
                    },
                  ),
                  2.hs,
                  const Text(
                    "Quel est la prémière raison de cette score?",
                    textAlign: TextAlign.center,
                  ),
                  1.5.hs,
                  const SizedBox(
                    height: 200,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                          hintText: "Dite nous ce vous en pensez..."),
                    ),
                  ),
                  2.hs,
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          onPressed: () {
                            Get.snackbar('Commentaire envoyer',
                                'Merci pour d\'avoir donner votre avis',
                                snackPosition: SnackPosition.BOTTOM);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Soumettre",
                            style: TextStyle(fontSize: 15),
                          )))
                ],
              ),
            ),
          ));
}
