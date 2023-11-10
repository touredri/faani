import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/src/tailleur_modeles.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../modele/modele.dart';
import '../my_theme.dart';

InputDecoration myInputDecoration(String label) {
  return InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black.withOpacity(0.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: inputBorderColor),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: inputBorderColor,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    labelText: label,
  );
}

class MyDropdownButton extends StatefulWidget {
  final String value;
  final ValueChanged<String?>? onChanged;
  final List<String> items;

  MyDropdownButton(
      {required this.value, required this.onChanged, required this.items});

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        border: Border.all(color: inputBorderColor),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          focusColor: inputBackgroundColor,
          dropdownColor: inputBackgroundColor,
          value: widget.value,
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: primaryColor),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

InputDecoration myInputDecorationWithIcon(String label, IconData icon) {
  return InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black.withOpacity(0.5),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: inputBorderColor),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: inputBorderColor,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    labelText: label,
    prefixIcon: Icon(
      icon,
      color: inputBorderColor,
    ),
  );
}

Container _myFilterContainer(String label, VoidCallback onPressed) {
  return Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    // margin: const EdgeInsets.only(top: 5),
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFA4CEFB)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w300,
              height: 0,
            ),
          ),
        ),
      ],
    ),
  );
}

TextButton myFilterContainer(String label, onPressed, String currentFilter) {
  bool v = currentFilter == label;
  return TextButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        decoration: ShapeDecoration(
          color: v ? primaryColor : null,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFA4CEFB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: v ? Colors.white : Colors.black,
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 0,
          ),
        ),
      ));
}

Stack homeItem(Modele modele) {
  return Stack(
    children: [
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: modele.fichier.length,
              itemBuilder: (context, imageIndex) {
                return Image.network(
                  modele.fichier[imageIndex]!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
      Container(
        alignment: Alignment.centerRight,
        child: Container(
          height: 240,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            color: Colors.white.withOpacity(0.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              FavoriteIcone(docId: modele.id!),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      // Handle the button press
                    },
                    icon: const Icon(
                      Icons.message_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Text('231', style: TextStyle(color: Colors.white)),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class FavoriteIcone extends StatefulWidget {
  final String docId;
  const FavoriteIcone({super.key, required this.docId});

  @override
  State<FavoriteIcone> createState() => _FavoriteIconeState();
}

class _FavoriteIconeState extends State<FavoriteIcone> {
  bool isFavorite = false;
  int likes = 0;
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
    FirebaseFirestore.instance
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: 'idUtilisateur')
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
    likeSnapshotStream = FirebaseFirestore.instance
        .collection('modele')
        .doc(widget.docId)
        .snapshots();
    FirebaseFirestore.instance
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .snapshots()
        .listen(onChange);
  }

  final firestore = FirebaseFirestore.instance;
  void createFavorie() async {
    final collection = firestore.collection('favorie');
    final docRef = await collection
        .add({'idModele': widget.docId, 'idUtilisateur': 'idUtilisateur'});
    print(docRef.id);
  }

  void deleteFavorie() async {
    final querySnapshot = await firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: 'idUtilisateur')
        .get();

    for (var doc in querySnapshot.docs) {
      await firestore.collection('favorie').doc(doc.id).delete();
    }
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
            icon: const Icon(
              Icons.favorite_border_outlined,
              color: Colors.white,
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
        Text(count.toString(), style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

void showSuccessDialog(BuildContext context, String text) {
  showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return AlertDialog(
        title: const Text('Parfait!'),
        content: Text(text.toString()),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const TailleurModeles()),
                (Route<dynamic> route) => route.isFirst,
              );
            },
          ),
        ],
      );
    },
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
