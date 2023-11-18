import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/modele/favorie.dart';
import 'package:faani/modele/modele.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/src/tailleur_modeles.dart';
import 'package:flutter/material.dart';

class FavoriesPage extends StatefulWidget {
  const FavoriesPage({super.key});

  @override
  State<FavoriesPage> createState() => _FavoriesPageState();
}

class _FavoriesPageState extends State<FavoriesPage> {
  List<Favorie> favorie = [];
  List<Modele> modeles = [];
  @override
  void initState() {
    super.initState();
  }

  Stream<List<Modele>> _loadData() async* {
    await for (var event in getAllFavorie('idUtilisateur')) {
      var modeles = <Modele>[];
      for (Favorie fav in event) {
        var modele = await getModele(fav.idModele!);
        modeles.add(modele);
      }
      yield modeles;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              const Text('Mes favoris', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryColor,
          toolbarHeight: 40,
        ),
        body: StreamBuilder<List<Modele>>(
          stream: _loadData(),
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
                    'Aucun favori!!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            } else {
              modeles = snapshot.data!;
              return MyListModele(modeles: modeles);
            }
          },
        ));
  }
}
