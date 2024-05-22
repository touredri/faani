import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';

Future commentaire(BuildContext context) {
  return showFloatingModalBottomSheet(
      context: context,
      horizontalPadding: 5,
      builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 500,
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
                  Row(
                    children: [
                      for (int i = 0; i < 10; i++)
                        const Icon(
                          Icons.star_outline_rounded,
                          size: 37,
                        )
                    ],
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
                          onPressed: () {},
                          child: const Text(
                            "Soumettre",
                            style: TextStyle(fontSize: 15),
                          )))
                ],
              ),
            ),
          ));
}
