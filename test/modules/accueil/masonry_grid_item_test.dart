import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/widgets/masonry_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forwards the model tap intention', (tester) async {
    var taps = 0;
    final modele = Modele(
      id: 'modele-1',
      detail: 'Boubou',
      fichier: const [''],
      imagePath: const <String>[],
      genreHabit: 'mixte',
      idTailleur: 'tailleur-1',
      idCategorie: 'categorie-1',
      isPublic: true,
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MasonryGridItem(
          modele: modele,
          onTap: () => taps++,
        ),
      ),
    ));

    await tester.tap(find.byType(MasonryGridItem));
    await tester.pump();

    expect(taps, 1);
  });
}
