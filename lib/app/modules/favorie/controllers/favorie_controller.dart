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
        // if (modele.idCategorie == "1" || modele.idCategorie == "8") {
        //   print("**********************added ${modele.idCategorie}");
        // }
        // if (listSelectedCategorie.isNotEmpty) {
        //   if (listSelectedCategorie.contains(modele.idCategorie)) {
        //     print("**********************added");
        //     models.add(modele);
        //   }
        // } else {
        if (modele != null) {
          models.add(modele);
        }
        // }
      }
      yield models;
    }
  }

  // category selected
  void onCategorieSelected(Categorie categorie) {
    print("**********************added ${categorie.id}");
    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.remove(categorie.id);
    } else {
      listSelectedCategorie.add(categorie.id);
    }
    // if (categorie.id == "1" && listSelectedCategorie.contains("8")) {
    //   listSelectedCategorie.remove("8");
    // } else if (categorie.id == "8" && listSelectedCategorie.contains("1")) {
    //   listSelectedCategorie.remove("1");
    // }
    loadData();
    update();
  }

  @override
  void onInit() async {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
