import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:flutter/material.dart';
import '../../../anonyme_profile.dart';
import '../../../widgets/widgets.dart';
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

  void favorieInit() {
    firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: user!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        print('found**************');
        setState(() {
          isFavorite = true;
        });
      } else
        print('${widget.docId} &&&&&&&& ${user!.uid}');
      print('not found in favorie');
    });
  }

  @override
  void initState() {
    super.initState();
    favorieInit();
  }

  void createFavorie() async {
    if (user!.isAnonymous) {
      showSuccessDialog(
          context,
          'Vous devez vous connecter pour ajouter ce modèle à vos favoris',
          AnonymeProfile());
      return;
    }
    FavorieService().create(widget.docId);
  }

  void deleteFavorie() async {
    if (user!.isAnonymous) {
      showSuccessDialog(
          context,
          'Vous devez vous connecter pour ajouter ce modèle à vos favoris',
          AnonymeProfile());
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
        IconButton(
            onPressed: () {
              if (isFavorite) {
                deleteFavorie();
                setState(() {
                  isFavorite = !isFavorite;
                });
              } else {
                createFavorie();
                setState(() {
                  isFavorite = !isFavorite;
                });
              }
            },
            icon: Icon(
              Icons.favorite_border_outlined,
              color: widget.color == 'white' ? Colors.white : Colors.grey,
              size: 30,
            ),
            isSelected: isFavorite,
            selectedIcon: const Icon(
              semanticLabel: 'Remove from favorites',
              textDirection: TextDirection.ltr,
              Icons.favorite,
              color: primaryColor,
              size: 30,
            )),
        // Text(count.toString(), style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
