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

  Stream<List<Modele>> loadData() async* {
    await for (var event in FavorieService().getAllFavorie(user!.uid)) {
      var modeles = <Modele>[];
      for (Favorie fav in event) {
        var modele = await ModeleService().getModeleById(fav.idModele!);
        if (selectedCategorie.value == null ||
            selectedCategorie.value!.libelle == 'Tous' ||
            modele.idCategorie == selectedCategorie.value!.id) {
          modeles.add(modele);
        }
      }
      yield modeles;
    }
  }

  // category selected
  void onCategorieSelected(Categorie categorie) {
    selectedCategorie.value = categorie;
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
