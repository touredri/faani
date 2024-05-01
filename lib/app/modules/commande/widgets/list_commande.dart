import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'commande_container.dart';

class ListCommande extends StatelessWidget {
  const ListCommande({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final CommandeController controller = Get.put(CommandeController());
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
            child: StreamBuilder(
                stream: status == "receive"
                    ? CommandeService().getAllCommandeByEtat(1)
                    : status == "finish"
                        ? CommandeService().getAllCommandeByEtat(0)
                        : status == "save"
                            ? CommandeService().getAllCommandeByEtat(2)
                            : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error1: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Center(
                        child: Column(
                      children: [
                        Image.asset('assets/images/no_commande.png',
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width),
                        Text(
                            textAlign: TextAlign.center,
                            status == 'receive'
                                ? 'Aucun habit en cour pour le moment, Ajouter une 👍'
                                : status == 'save'
                                    ? 'Oups !! No data'
                                    : 'Oups !! vous n\'avez pas d\'habit terminer'),
                      ],
                    ));
                  } else {
                    List<Commande> commande = snapshot.data as List<Commande>;
                    return GridView.builder(
                        itemCount: commande.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 13,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 1.7),
                        ),
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future:
                                  controller.fetchCommandeData(commande[index]),
                              builder: (context, result) {
                                if (result.connectionState ==
                                    ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 200.0,
                                      height: 200.0,
                                      color: Colors.white,
                                    ),
                                  );
                                } else if (result.hasError) {
                                  return Text('Error2: ${result.error}');
                                } else {
                                  final tailleur = result.data![0] as UserModel;
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(
                                          () => DetailCommandeView(
                                              commande[index]),
                                          transition: Transition.downToUp);
                                    },
                                    child: CommandeContainer(
                                      imageUrl: commande[index].modeleImage,
                                      nomPrenom: controller
                                              .userController.isTailleur.value
                                          ? commande[index].nomClient
                                          : tailleur.nomPrenom!,
                                      dateCommande:
                                          commande[index].dateAjout,
                                      etat: commande[index].etatLibelle,
                                    ),
                                  );
                                }
                              });
                        });
                  }
                })),
      ]),
    );
  }
}
