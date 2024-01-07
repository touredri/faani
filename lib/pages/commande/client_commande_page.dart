import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/modele/classes.dart';
import 'package:faani/models/commande_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:faani/services/commande_service.dart';
import 'package:faani/src/detait_commande_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import 'firebase_get_all_data.dart';
// import 'my_theme.dart';

class ClientCommandeFormPage extends StatefulWidget {
  const ClientCommandeFormPage({super.key});

  @override
  State<ClientCommandeFormPage> createState() => _CommandePageState();
}

class _CommandePageState extends State<ClientCommandeFormPage> {
  final TextEditingController _filter = TextEditingController();
  CommandeService commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    _filter.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          title: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const Text(
                'Commandes',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          backgroundColor: primaryColor,
          toolbarHeight: 50,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          )),
      body: Container(
        color: Color.fromARGB(255, 250, 248, 248),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _filter,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  labelText: 'Chercher par nom',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  fillColor: inputBackgroundColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Expanded(
            //   child: StreamBuilder(
            //       stream: commandeService.getAllCommande(isTailleur),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const Center(child: CircularProgressIndicator());
            //         } else if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         } else if (!snapshot.hasData) {
            //           return const Center(
            //               child: Text('Aucune commande pour le moment'));
            //         } else {
            //           List<Commande> commande = snapshot.data as List<Commande>;
            //           if (_filter.text.isNotEmpty) {
            //             commande = commande
            //                 .where((element) => element.id
            //                     .toLowerCase()
            //                     .contains(_filter.text.toLowerCase()))
            //                 .toList();
            //           }
            //           return ListView.builder(
            //               itemCount: commande.length,
            //               itemBuilder: (context, index) {
            //                 final currentCommande = commande[index];
            //                 return FutureBuilder<Tailleur>(
            //                   future:
            //                       getTailleurById(currentCommande.idTailleur),
            //                   builder: (context, snapshot) {
            //                     if (snapshot.connectionState ==
            //                         ConnectionState.waiting) {
            //                       return CircularProgressIndicator();
            //                     } else if (snapshot.hasError) {
            //                       return Text('Error: ${snapshot.error}');
            //                     } else {
            //                       Tailleur tailleur = snapshot.data!;
            //                       return GestureDetector(
            //                         onTap: () {
            //                           Navigator.of(context).push(
            //                               MaterialPageRoute(
            //                                   builder: (BuildContext context) =>
            //                                       DetailCommandeClient(
            //                                         commande: currentCommande,
            //                                       )));
            //                         },
            //                         child: Container(
            //                           // color: Colors.white,
            //                           padding: const EdgeInsets.all(10),
            //                           height: 140,
            //                           child: Card(
            //                             color: Colors.white,
            //                             child: Row(
            //                               children: [
            //                                 ClipRRect(
            //                                   borderRadius:
            //                                       BorderRadius.circular(10),
            //                                   child: SizedBox(
            //                                     width: 120,
            //                                     height: 180,
            //                                     child: CachedNetworkImage(
            //                                       fit: BoxFit.fill,
            //                                       imageUrl: currentCommande.id,
            //                                       placeholder: (context, url) =>
            //                                           Placeholder(),
            //                                       errorWidget:
            //                                           (context, url, error) =>
            //                                               Placeholder(),
            //                                     ),
            //                                   ),
            //                                 ),
            //                                 Expanded(
            //                                   child: Padding(
            //                                     padding:
            //                                         const EdgeInsets.all(8.0),
            //                                     child: Column(
            //                                       crossAxisAlignment:
            //                                           CrossAxisAlignment.start,
            //                                       mainAxisAlignment:
            //                                           MainAxisAlignment
            //                                               .spaceBetween,
            //                                       children: [
            //                                         Column(
            //                                           crossAxisAlignment:
            //                                               CrossAxisAlignment
            //                                                   .start,
            //                                           children: [
            //                                             Text(
            //                                                 tailleur.nomPrenom),
            //                                             TextButton(
            //                                               onPressed: () {
            //                                                 currentCommande
            //                                                     .delete();
            //                                                 setState(() {});
            //                                               },
            //                                               child: const Text(''),
            //                                             ),
            //                                           ],
            //                                         ),
            //                                         Text(DateFormat(
            //                                                 'dd-MM-yyyy')
            //                                             .format(currentCommande
            //                                                 .dateCommande!)
            //                                             .toString()),
            //                                       ],
            //                                     ),
            //                                   ),
            //                                 ),
            //                                 const SizedBox(
            //                                   child: Text('En cours'),
            //                                 )
            //                               ],
            //                             ),
            //                           ),
            //                         ),
            //                       );
            //                     }
            //                   },
            //                 );
            //               });
            //         }
            //       }),
            // ),
          ],
        ),
      ),
    );
  }
}
