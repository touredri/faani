import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
import 'package:faani/auth.dart';
import 'package:faani/src/form_client_modele.dart';
import 'package:faani/src/form_comm_tailleur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../firebase_get_all_data.dart';
import '../modele/modele.dart';
import '../my_theme.dart';
import 'message_modal.dart';

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

Stack homeItem(Modele modele, BuildContext context) {
  final bool isTailleur = Provider.of<ApplicationState>(context).isTailleur;
  print('isTailleur: $isTailleur');
  final PageController _controller = PageController();
  return Stack(
    children: [
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: modele.fichier.length,
              itemBuilder: (context, imageIndex) {
                return CachedNetworkImage(
                  imageUrl: modele.fichier[imageIndex]!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: 20,
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: modele.fichier.length,
                      effect: const ExpandingDotsEffect(
                        dotColor: Colors.grey,
                        activeDotColor: primaryColor,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
      Container(
        alignment: Alignment.centerRight,
        child: Container(
          height: 261,
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
                onPressed: () {
                  if (!isTailleur) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientCommande(
                          modele: modele,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TailleurCommandeForm(
                          modele: modele,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              FavoriteIcone(docId: modele.id!),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            // isScrollControlled: true,
                            backgroundColor:
                                const Color.fromARGB(255, 252, 248, 248),
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 600,
                                padding: const EdgeInsets.only(
                                    top: 20, left: 8, right: 8),
                                child: MessageModal(
                                  idModele: modele.id!,
                                ),
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: getNombreMessage(modele.id!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('${snapshot.data}',
                              style: TextStyle(color: Colors.grey));
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
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
  final firestore = FirebaseFirestore.instance;

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
    final collection = firestore.collection('favorie');
    await collection
        .add({'idModele': widget.docId, 'idUtilisateur': user!.uid});
    // print(docRef.id);
  }

  void deleteFavorie() async {
    final querySnapshot = await firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: user!.uid)
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
              color: Colors.grey,
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
        Text(count.toString(), style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

void showSuccessDialog(BuildContext context, String text, Widget page) {
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
                MaterialPageRoute(builder: (BuildContext context) => page),
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

Widget BackButton(BuildContext context) {
  return IconButton(
    icon: const Icon(
      Icons.arrow_back_ios,
      color: Colors.white,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
