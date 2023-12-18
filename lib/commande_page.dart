import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app_state.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/modele/commande.dart';
import 'package:faani/src/detail_commande.dart';
import 'package:faani/src/new_commande.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'firebase_get_all_data.dart';
import 'my_theme.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  final TextEditingController _filter = TextEditingController();
  @override
  void initState() {
    super.initState();
    _filter.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bool isTailleur = Provider.of<ApplicationState>(context).isTailleur;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          title: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Commandes',
                style: Theme.of(context).textTheme.displayMedium,
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
        color: const Color.fromARGB(255, 250, 248, 248),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _filter,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  floatingLabelStyle: const TextStyle(
                    color: primaryColor,
                  ),
                  labelText: 'Chercher par nom',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  fillColor: inputBackgroundColor,
                  labelStyle: TextStyle(
                    color: subtextColor,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide(
                      color: inputBorderColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: getAllCommandeAnnonyme(user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return const Center(
                          child: Text('Aucune commande pour le moment'));
                    } else {
                      List<CommandeAnonyme> commande =
                          snapshot.data as List<CommandeAnonyme>;
                      if (_filter.text.isNotEmpty) {
                        commande = commande
                            .where((element) => element.nomClient!
                                .toLowerCase()
                                .contains(_filter.text.toLowerCase()))
                            .toList();
                      }
                      return ListView.builder(
                          itemCount: commande.length,
                          itemBuilder: (context, index) {
                            final currentCommande = commande[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DetailCommande(
                                          commande: currentCommande,
                                        )));
                              },
                              child: Container(
                                // color: Colors.white,
                                padding: const EdgeInsets.all(10),
                                height: 140,
                                child: Card(
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 120,
                                          height: 180,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl:
                                                currentCommande.image ?? "",
                                            placeholder: (context, url) =>
                                                const Placeholder(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Placeholder(),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(currentCommande
                                                      .nomClient!),
                                                  TextButton(
                                                    onPressed: () {
                                                      currentCommande.delete();
                                                      setState(() {});
                                                    },
                                                    child:
                                                        const Text('Annuler'),
                                                  ),
                                                ],
                                              ),
                                              Text(DateFormat('dd-MM-yyyy')
                                                  .format(currentCommande
                                                      .dateCommande!)
                                                  .toString()),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        child: Text('En cours'),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: isTailleur,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const NouvelleCommande(),
              settings: const RouteSettings(name: 'CommandePage'),
            ));
          },
          backgroundColor: Colors.grey,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
