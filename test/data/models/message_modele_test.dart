import 'package:faani/app/data/models/message_modele.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes conversation read state and command context', () {
    final message = MessageModel(
      fromId: 'client-1',
      toId: 'tailor-1',
      commandeId: 'order-1',
      commandeTitle: 'Boubou bleu',
      unreadFor: const ['tailor-1'],
      lastSenderId: 'client-1',
    );

    final map = message.toMap();

    expect(map['commande_id'], 'order-1');
    expect(map['commande_title'], 'Boubou bleu');
    expect(map['unread_for'], ['tailor-1']);
    expect(map['last_sender_id'], 'client-1');
  });
}
