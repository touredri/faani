import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../data/models/modele_model.dart';
import '../../../style/my_theme.dart';
import '../../globale_widgets/list_categorie.dart';
import '../../globale_widgets/modele_card.dart';
import '../controllers/favorie_controller.dart';

class FavorieView extends GetView<FavorieController> {
  const FavorieView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FavorieController());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 40.0,
          title: Text('Mes favories',
              style: Theme.of(context).textTheme.displayMedium),
          bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 30),
              child: Container(
                color: primaryColor,
                height: 30,
                padding: const EdgeInsets.only(bottom: 5),
                width: MediaQuery.of(context).size.width,
                child: CategorieFiltre(
                  controller: controller,
                ),
              )),
        ),
        body: GetBuilder<FavorieController>(
          init: FavorieController(),
          initState: (_) {},
          // id: 'favorie',
          builder: (_) {
            return StreamBuilder<List<Modele>>(
              stream: controller.loadData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      Image.asset('assets/images/no_favori.png'),
                      const Text(
                        'Oups 😊 Vous n\'avez pas mis de modèle en favorie',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                } else {
                  controller.modeles.value = snapshot.data!;
                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return buildCard(controller.modeles.value[index]!,
                          context: context);
                    },
                  );
                }
              },
            );
          },
        ));
  }
}
