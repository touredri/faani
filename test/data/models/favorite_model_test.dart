import 'package:faani/app/data/models/favorite_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps legacy favorites available without collections', () {
    final favorite = Favorie.fromData(
      id: 'favorite-1',
      data: const <String, dynamic>{
        'idModele': 'modele-1',
        'idUtilisateur': 'user-1',
      },
    );

    expect(favorite.collectionIds, isEmpty);
    expect(favorite.toMap()['idUtilisateur'], 'user-1');
  });

  test('reads collection assignments and the previous idUser field', () {
    final favorite = Favorie.fromData(
      id: 'favorite-1',
      data: const <String, dynamic>{
        'idModele': 'modele-1',
        'idUser': 'user-1',
        'collectionIds': <String>['wedding', 'weekend'],
      },
    );

    expect(favorite.idUtilisateur, 'user-1');
    expect(favorite.collectionIds, ['wedding', 'weekend']);
  });
}
