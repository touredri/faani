// import 'package:faani/app/data/models/modele_model.dart';
// import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
// import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
// import 'package:faani/app/modules/globale_widgets/modele_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';

// class ChooseModeleView extends GetView<CommandeController> {
//   const ChooseModeleView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: primaryBackAppBar('Choisir un modèle'),
//         body: SafeArea(
//           child: FutureBuilder<Modele>(
//             future: controller.getModeles(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else {
//                 return MasonryGridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 4,
//                   crossAxisSpacing: 4,
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     return buildCard(snapshot.data![index], context: context);
//                   },
//                 );
//               }
//             },
//           ),
//         ));
//   }
// }
