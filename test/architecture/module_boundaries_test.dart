import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('critical controllers keep the extracted module boundaries', () {
    final auth = File(
      'lib/app/modules/authentification/controllers/authentification_controller.dart',
    ).readAsStringSync();
    final order = File(
      'lib/app/modules/commande/controllers/commande_controller.dart',
    ).readAsStringSync();
    final profile = File(
      'lib/app/modules/profile/controllers/profile_controller.dart',
    ).readAsStringSync();

    expect(auth, isNot(contains('modules/accueil/controllers')));
    expect(auth, isNot(contains('modules/commande/controllers')));
    expect(auth, isNot(contains('modules/profile/controllers')));
    expect(order, isNot(contains('AccueilController')));
    expect(order, isNot(contains('FirebaseFirestore.instance')));
    expect(profile, isNot(contains('Get.put(')));
    expect(profile, isNot(contains('FirebaseFirestore.instance')));
  });
}
