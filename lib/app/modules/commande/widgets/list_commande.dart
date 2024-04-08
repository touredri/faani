import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'commande_container.dart';

class ListCommande extends StatelessWidget {
  const ListCommande({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
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
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (result.hasError) {
                                  return Text('Error2: ${result.error}');
                                } else {
                                  Modele modele = result.data![2] as Modele;
                                  UserModel tailleur =
                                      result.data![0] as UserModel;
                                  UserModel? client = result.data![1] != null
                                      ? result.data![1] as UserModel
                                      : null;
                                  String etat = result.data![3] as String;
                                  final String? nomPrenom =
                                      userController.isTailleur.value
                                          ? client?.nomPrenom ??
                                              commande[index].nomClient
                                          : tailleur.nomPrenom;
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => DetailCommandeView(modele),
                                          transition: Transition.downToUp);
                                      // if (commande[index].idCategorie == null){
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => SaveCommande(
                                      //         idCommande: commande[index].id,
                                      //         idClient: client.id,
                                      //         idTailleur: tailleur.id,
                                      //         idModele: modele.id,
                                      //         isTailleur: isTailleur,
                                      //       ),
                                      //     ),
                                      //   );}
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => DetailCommande(
                                      //       commandeId: commande[index].id,
                                      //       isAnnonyme: true,
                                      //       modele: modele,
                                      //       idCategorie:
                                      //           commande[index].idCategorie,
                                      //       tailleur: tailleur,
                                      //       client: client,
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                    child: CommandeContainer(
                                      imageUrl: modele.fichier[0]!,
                                      nomPrenom: nomPrenom,
                                      dateCommande:
                                          commande[index].dateAjout.toString(),
                                      etat: etat,
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
