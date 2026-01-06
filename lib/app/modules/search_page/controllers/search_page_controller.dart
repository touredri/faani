import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;
  final StreamController<List<Modele>> _searchResultsController =
      StreamController<List<Modele>>();
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  static const int _pageSize = 10;

  Stream<List<Modele>> searchResultsStream() => _searchResultsController.stream;

  void onTextChange(String text) {
    searchText.value = text;
    _lastDocument = null;
    _hasMoreData = true;
    _searchResultsController.add(<Modele>[]);
    _search();
  }

  void _search() async {
    if (searchText.value.isEmpty) {
      _searchResultsController.add(<Modele>[]);
    } else if (_hasMoreData) {
      Query query = FirebaseFirestore.instance
          .collection('modele')
          .where('detail',
              isGreaterThanOrEqualTo: searchText.value.toLowerCase())
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        List<Modele> list = querySnapshot.docs.map((doc) {
          return Modele.fromDocumentSnapshot(doc);
        }).toList();

        _searchResultsController.add(list);
      } else {
        _hasMoreData = false;
      }
    }
  }

  void loadMore() {
    if (_hasMoreData) {
      _search();
    }
  }



  @override
  void onClose() {
    _searchResultsController.close();
    super.onClose();
  }
}
