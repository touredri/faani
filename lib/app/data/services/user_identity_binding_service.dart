import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/firebase/global_function.dart';

class UserIdentityBindingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String normalizePhoneE164(String rawPhone) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return '';

    final withoutSpaces = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (withoutSpaces.startsWith('+')) {
      return '+${withoutSpaces.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }

    if (withoutSpaces.startsWith('00')) {
      final digits = withoutSpaces.substring(2).replaceAll(RegExp(r'\D'), '');
      return digits.isEmpty ? '' : '+$digits';
    }

    final digits = withoutSpaces.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return '+$digits';
  }

  Future<void> bindCurrentUserIdentity({
    required String phoneNumber,
    String? email,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    final uid = currentUser.uid;
    final normalizedPhone = normalizePhoneE164(phoneNumber);
    final normalizedEmail =
        (email ?? currentUser.email ?? '').trim().toLowerCase();
    final providerIds = currentUser.providerData
        .map((provider) => provider.providerId)
        .where((providerId) => providerId.trim().isNotEmpty)
        .toSet()
        .toList();

    final userRef = _firestore.collection('users').doc(uid);
    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      if (normalizedPhone.isNotEmpty) {
        final phoneIndexRef =
            _firestore.collection('phone_index').doc(normalizedPhone);
        final phoneIndexDoc = await transaction.get(phoneIndexRef);

        if (phoneIndexDoc.exists) {
          final ownerUid = (phoneIndexDoc.data()?['uid'] ?? '').toString();
          if (ownerUid.isNotEmpty && ownerUid != uid) {
            throw Exception(
              'Ce numéro est déjà lié à un autre compte.',
            );
          }
        }

        transaction.set(
            phoneIndexRef,
            {
              'uid': uid,
              'phoneE164': normalizedPhone,
              'updatedAt': now,
            },
            SetOptions(merge: true));
      }

      transaction.set(
          userRef,
          {
            'id': uid,
            'phoneNumber': phoneNumber,
            'phoneE164': normalizedPhone,
            'email': normalizedEmail,
            'authProviders': providerIds,
            'identityBoundAt': now,
            'updatedAt': now,
          },
          SetOptions(merge: true));
    });
  }

  Future<void> syncCurrentUserIdentityFromFirestore() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) return;

    final data = userDoc.data() ?? <String, dynamic>{};
    final phone = (data['phoneNumber'] ?? '').toString();
    final email = (data['email'] ?? currentUser.email ?? '').toString();

    if (phone.trim().isEmpty && email.trim().isEmpty) return;

    await bindCurrentUserIdentity(
      phoneNumber: phone,
      email: email,
    );
  }
}
