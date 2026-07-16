import 'package:faani/app/data/services/model_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists and restores a publication draft', () async {
    const draft = ModelPublicationDraft(
      detail: 'Boubou de cérémonie',
      categoryId: 'categorie-2',
      gender: 'Femme',
      isPublic: true,
      imagePaths: ['/tmp/front.jpg', '/tmp/detail.jpg'],
    );
    const store = ModelDraftStore();

    await store.save('user-1', draft);
    final loaded = await store.load('user-1');

    expect(loaded?.detail, draft.detail);
    expect(loaded?.categoryId, draft.categoryId);
    expect(loaded?.gender, draft.gender);
    expect(loaded?.isPublic, isTrue);
    expect(loaded?.imagePaths, draft.imagePaths);
  });

  test('clears a draft and ignores malformed data', () async {
    SharedPreferences.setMockInitialValues({
      'model_publication_draft_user-1': '{not-json',
    });
    const store = ModelDraftStore();

    expect(await store.load('user-1'), isNull);
    expect(await store.load('user-1'), isNull);

    await store.save(
      'user-1',
      const ModelPublicationDraft(
        detail: 'Test',
        categoryId: '2',
        gender: 'Homme',
        isPublic: false,
        imagePaths: [],
      ),
    );
    await store.clear('user-1');
    expect(await store.load('user-1'), isNull);
  });
}
