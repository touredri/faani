import 'dart:convert';

import 'package:faani/app/domain/order/order_form_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDraftStore {
  static const _keyPrefix = 'order_form_draft_';

  Future<OrderFormDraft?> read(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString('$_keyPrefix$userId');
    if (rawValue == null || rawValue.isEmpty) return null;
    try {
      return OrderFormDraft.fromJson(
          jsonDecode(rawValue) as Map<String, dynamic>);
    } on FormatException {
      await preferences.remove('$_keyPrefix$userId');
      return null;
    }
  }

  Future<void> save(String userId, OrderFormDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_keyPrefix$userId',
      jsonEncode(draft.toJson()),
    );
  }

  Future<void> clear(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_keyPrefix$userId');
  }
}
