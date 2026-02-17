import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter/material.dart';
import '../../firebase/global_function.dart';
import '../../style/app_colors.dart';

abstract class BaseIcon extends StatefulWidget {
  final String docId;
  final Color color;
  const BaseIcon({super.key, required this.docId, this.color = Colors.white});
}

abstract class BaseIconState<T extends BaseIcon> extends State<T> {
  bool isActive = false;
  final firestore = FirebaseFirestore.instance;
  int count = 0;

  void onChange(QuerySnapshot snapshot) {
    if (mounted) {
      setState(() {
        count = snapshot.docs.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    getSnapshotStream().listen(onChange);
  }

  void toggleActive();

  void init();

  Stream<QuerySnapshot> getSnapshotStream();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            toggleActive();
            setState(() {
              isActive = !isActive;
            });
          },
          child: Icon(
            isActive ? getActiveIcon() : getInactiveIcon(),
            color: isActive ? AppColors.primary : widget.color,
            size: 30,
          ),
        ),
        Text(count.toString(), style: TextStyle(color: widget.color)),
      ],
    );
  }

  IconData getActiveIcon();

  IconData getInactiveIcon();
}

class FavoriteIcone extends BaseIcon {
  const FavoriteIcone({super.key, required super.docId, super.color});

  @override
  State<FavoriteIcone> createState() => _FavoriteIconeState();
}

class _FavoriteIconeState extends BaseIconState<FavoriteIcone> {
  @override
  void init() {
    firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .where('idUtilisateur', isEqualTo: user?.uid ?? '')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          isActive = true;
        });
      }
    });
  }

  @override
  void toggleActive() {
    if (isActive) {
      FavorieService().delete(widget.docId);
    } else {
      FavorieService().create(widget.docId);
    }
  }

  @override
  Stream<QuerySnapshot> getSnapshotStream() {
    return firestore
        .collection('favorie')
        .where('idModele', isEqualTo: widget.docId)
        .snapshots();
  }

  @override
  IconData getActiveIcon() => Icons.favorite;

  @override
  IconData getInactiveIcon() => Icons.favorite_border;
}

class LikeIcon extends BaseIcon {
  const LikeIcon({super.key, required super.docId, super.color});

  @override
  State<LikeIcon> createState() => _LikeIconState();
}

class _LikeIconState extends BaseIconState<LikeIcon> {
  @override
  void init() {
    firestore
        .collection('modele')
        .doc(widget.docId)
        .collection('likes')
        .where('idUser', isEqualTo: user?.uid ?? '')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          isActive = true;
        });
      }
    });
  }

  @override
  void toggleActive() {
    if (isActive) {
      removeLike();
    } else {
      addLike();
    }
  }

  void addLike() async {
    if (user == null) {
      return;
    }
    await ModeleService().addLike(widget.docId, user!.uid);
  }

  void removeLike() async {
    if (user == null) {
      return;
    }
    final likeSnapshot = await firestore
        .collection('modele')
        .doc(widget.docId)
        .collection('likes')
        .where('idUser', isEqualTo: user!.uid)
        .get();
    if (likeSnapshot.docs.isNotEmpty) {
      await ModeleService()
          .removeLike(widget.docId, likeSnapshot.docs.first.id);
    }
  }

  @override
  Stream<QuerySnapshot> getSnapshotStream() {
    return firestore
        .collection('modele')
        .doc(widget.docId)
        .collection('likes')
        .snapshots();
  }

  @override
  IconData getActiveIcon() => Icons.thumb_up;

  @override
  IconData getInactiveIcon() => Icons.thumb_up_off_alt;
}
