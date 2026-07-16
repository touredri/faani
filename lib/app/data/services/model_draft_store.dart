import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ModelPublicationDraft {
  const ModelPublicationDraft({
    required this.detail,
    required this.categoryId,
    required this.gender,
    required this.isPublic,
    required this.imagePaths,
  });

  final String detail;
  final String categoryId;
  final String gender;
  final bool isPublic;
  final List<String> imagePaths;

  Map<String, dynamic> toJson() => {
        'detail': detail,
        'categoryId': categoryId,
        'gender': gender,
        'isPublic': isPublic,
        'imagePaths': imagePaths,
      };

  factory ModelPublicationDraft.fromJson(Map<String, dynamic> json) {
    final rawPaths = json['imagePaths'];
    return ModelPublicationDraft(
      detail: (json['detail'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? '').toString(),
      gender: (json['gender'] ?? 'Homme').toString(),
      isPublic: json['isPublic'] != false,
      imagePaths: rawPaths is List
          ? rawPaths.map((path) => path.toString()).toList()
          : const <String>[],
    );
  }
}

class ModelDraftStore {
  const ModelDraftStore({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;
  static const _keyPrefix = 'model_publication_draft_';

  Future<SharedPreferences> _getPreferences() async {
    if (_preferences != null) return _preferences!;
    return SharedPreferences.getInstance();
  }

  Future<ModelPublicationDraft?> load(String userId) async {
    final preferences = await _getPreferences();
    final raw = preferences.getString('$_keyPrefix$userId');
    if (raw == null || raw.isEmpty) return null;
    try {
      return ModelPublicationDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await clear(userId);
      return null;
    }
  }

  Future<void> save(String userId, ModelPublicationDraft draft) async {
    final preferences = await _getPreferences();
    await preferences.setString(
      '$_keyPrefix$userId',
      jsonEncode(draft.toJson()),
    );
  }

  Future<void> clear(String userId) async {
    final preferences = await _getPreferences();
    await preferences.remove('$_keyPrefix$userId');
  }
}
