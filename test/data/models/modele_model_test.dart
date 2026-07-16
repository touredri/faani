import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes searchable model content when it is persisted', () {
    final modele = Modele(
      id: 'modele-1',
      detail: 'Boubou cérémonié',
      fichier: const <String>[],
      imagePath: const <String>[],
      genreHabit: 'Femme',
      idTailleur: 'tailleur-1',
      idCategorie: 'mariage',
      isPublic: true,
    );

    expect(modele.searchableText, 'boubou ceremonie femme mariage');
    expect(modele.toMap()['searchText'], modele.searchableText);
  });

  test('persists the Faani content origin', () {
    final modele = Modele(
      id: 'modele-faani',
      detail: 'Collection Faani',
      fichier: const <String>[],
      imagePath: const <String>[],
      genreHabit: 'Homme',
      idTailleur: 'admin-1',
      idCategorie: 'boubou',
      isPublic: true,
      isFaaniContent: true,
    );

    expect(modele.toMap()['isFaaniContent'], isTrue);
  });
}
