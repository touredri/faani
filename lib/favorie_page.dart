import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/modele/favorie.dart';
import 'package:faani/modele/modele.dart';
import 'package:faani/my_theme.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    getAllFavorie('idUtilisateur').listen((event) {
      setState(() {
        favorie = event;
        print(favorie.length);

        for (Favorie fav in favorie) {
          // print(fav.idModele);
          getModele(fav.idModele!).then((value) => {
                setState(() {
                  print(value);
                  if (value != null) {
                    modeles.add(value);
                  }
                })
              });
        }
      });
    });

    // print(modeles.length);
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
        body: Container(
          child: ListView.builder(
            itemCount: favorie.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(favorie[index].idModele!),
              );
            },
          ),
        ));
  }
}
