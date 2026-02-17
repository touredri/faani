import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../firebase/global_function.dart';
import '../../style/app_colors.dart';

abstract class BaseIcon extends StatefulWidget {
  final String docId;
  final Color color;
  const BaseIcon({super.key, required this.docId, this.color = Colors.white});
}

abstract class BaseIconState<T extends BaseIcon> extends State<T>
    with SingleTickerProviderStateMixin {
  bool isActive = false;
  final firestore = FirebaseFirestore.instance;
  int count = 0;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

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
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);
    init();
    getSnapshotStream().listen(onChange);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
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
            HapticFeedback.lightImpact();
            toggleActive();
            setState(() {
              isActive = !isActive;
            });
            _scaleController.forward(from: 0);
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  isActive ? getActiveIcon() : getInactiveIcon(),
                  color: isActive ? AppColors.primary : widget.color,
                  size: 26,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        Text(count.toString(),
            style: TextStyle(color: widget.color, fontSize: 11)),
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
