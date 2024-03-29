import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/styles.dart';
import '../../../data/models/modele_model.dart';
import '../../globale_widgets/modele_card.dart';
import '../controllers/favorie_controller.dart';

class FavorieView extends GetView<FavorieController> {
  const FavorieView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FavorieController controller = Get.put(FavorieController());
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        backgroundColor: primaryColor,
        expandedHeight: 40.0,
        floating: true,
        snap: true,
        title: Text('Mes favories',
            style: Theme.of(context).textTheme.displayMedium),
      ),
      // SliverPersistentHeader(delegate: delegate)
      SliverList(
          delegate: SliverChildListDelegate([
        StreamBuilder<List<Modele>>(
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
              return ModeleCard(modeles: snapshot.data!);
            }
          },
        ),
      ]))
    ]));
  }
}
