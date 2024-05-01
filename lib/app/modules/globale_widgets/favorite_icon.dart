import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:flutter/material.dart';
import '../profile/views/anonyme_profile.dart';
import '../../firebase/global_function.dart';
import '../../style/my_theme.dart';

class FavoriteIcone extends StatefulWidget {
  final String docId, color;
  const FavoriteIcone({super.key, required this.docId, required this.color});

  @override
  State<FavoriteIcone> createState() => _FavoriteIconeState();
}

class _FavoriteIconeState extends State<FavoriteIcone> {
  bool isFavorite = false;
  final firestore = FirebaseFirestore.instance;
  int count = 0;
  Stream<DocumentSnapshot>? likeSnapshotStream;
  final streamController = StreamController<DocumentSnapshot>();

  void onChange(QuerySnapshot snapshot) {
    if (mounted) {
      setState(() {
        count = snapshot.docs.length;
      });
    }
  }

  void favorieInit() {
    firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: user!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          isFavorite = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    favorieInit();
    likeSnapshotStream =
        firestore.collection('modele').doc(widget.docId).snapshots();
    firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .snapshots()
        .listen(onChange);
  }

  void createFavorie() async {
    if (user!.isAnonymous) {
      // make
      // showSuccessDialog(
      //     context,
      //     'Vous devez vous connecter pour ajouter ce modèle à vos favoris',
      //     AnonymeProfile()
      //     );
      return;
    }
    FavorieService().create(widget.docId);
  }

  void deleteFavorie() async {
    if (user!.isAnonymous) {
      // showSuccessDialog(
      //     context,
      //     'Vous devez vous connecter pour ajouter ce modèle à vos favoris',
      //     AnonymeProfile());
      return;
    }
    FavorieService().delete(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (isFavorite) {
              deleteFavorie();
            } else {
              createFavorie();
            }
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? primaryColor
                : (widget.color == 'white' ? Colors.white : Colors.black),
            size: 30,
          ),
        ),
        Text(count.toString(), style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
