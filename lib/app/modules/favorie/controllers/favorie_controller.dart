import 'package:faani/app/data/models/categorie_model.dart';
import 'package:get/get.dart';
import '../../../data/models/favorite_model.dart';
import '../../../data/models/modele_model.dart';
import '../../../data/services/favorite_service.dart';
import '../../../data/services/modele_service.dart';
import '../../../firebase/global_function.dart';

class FavorieController extends GetxController {
  Rx<List<Modele?>> modeles = Rx<List<Modele?>>([]);
  Rx<Categorie?> selectedCategorie = Rx<Categorie?>(null);
  RxList<String> listSelectedCategorie = <String>[].obs;

  Stream<List<Modele>> loadData() async* {
    await for (var event in FavorieService().getAllFavorie(user!.uid)) {
      var models = <Modele>[];
      for (Favorie fav in event) {
        var modele = await ModeleService()
            .getModelByIdAndCategories(fav.idModele!, listSelectedCategorie);
        if (modele != null) {
          models.add(modele);
        }
      }
      yield models;
    }
  }

  // category selected
  void onCategorieSelected(Categorie categorie) {
    if (categorie.id == 'all') {
      listSelectedCategorie.clear();
      selectedCategorie.value = null;
      update();
      return;
    }

    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.clear();
      selectedCategorie.value = null;
    } else {
      listSelectedCategorie.assignAll([categorie.id]);
      selectedCategorie.value = categorie;

      if (categorie.id == '1') {
        listSelectedCategorie.remove('8');
      } else if (categorie.id == '8') {
        listSelectedCategorie.remove('1');
      }
    }

    update();
  }
}
