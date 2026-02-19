import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;
  final RxList<Modele> results = <Modele>[].obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> recentQueries = <String>[].obs;

  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  Worker? _searchDebounce;
  static const int _pageSize = 10;
  static const String _recentQueriesKey = 'recent_search_queries';

  void onTextChange(String text) {
    searchText.value = text;
  }

  @override
  void onInit() {
    super.onInit();
    _loadRecentQueries();
    _searchDebounce = debounce<String>(
      searchText,
      (_) => _startFreshSearch(),
      time: const Duration(milliseconds: 350),
    );
  }

  Future<void> _loadRecentQueries() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_recentQueriesKey) ?? <String>[];
    recentQueries.assignAll(cached);
  }

  Future<void> _persistRecentQueries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentQueriesKey, recentQueries.toList());
  }

  Future<void> addRecentQuery(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    recentQueries
        .removeWhere((q) => q.toLowerCase() == normalized.toLowerCase());
    recentQueries.insert(0, normalized);
    if (recentQueries.length > 8) {
      recentQueries.removeRange(8, recentQueries.length);
    }
    await _persistRecentQueries();
  }

  Future<void> clearRecentQueries() async {
    recentQueries.clear();
    await _persistRecentQueries();
  }

  Future<void> _startFreshSearch() async {
    final queryText = searchText.value.trim().toLowerCase();

    _lastDocument = null;
    _hasMoreData = true;
    hasMoreData.value = true;
    hasError.value = false;
    errorMessage.value = '';
    results.clear();

    if (queryText.isEmpty) {
      return;
    }

    final cached = ModeleService().getCachedSearch(queryText);
    if (cached.isNotEmpty) {
      results.assignAll(cached);
      addRecentQuery(queryText);
      _refreshSearchCacheInBackground(queryText);
      return;
    }

    isInitialLoading.value = true;
    try {
      final page = await _fetchNextPage(queryText);
      results.assignAll(page);
      ModeleService().setCachedSearch(queryText, results);
      addRecentQuery(queryText);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> _refreshSearchCacheInBackground(String queryText) async {
    _lastDocument = null;
    _hasMoreData = true;
    try {
      final page = await _fetchNextPage(queryText);
      if (page.isNotEmpty) {
        results.assignAll(page);
        ModeleService().setCachedSearch(queryText, results);
      }
    } catch (_) {
      // keep cached results on background refresh failure
    }
  }

  Future<List<Modele>> _fetchNextPage(String queryText) async {
    Query query = FirebaseFirestore.instance
        .collection('modele')
        .where('detail', isGreaterThanOrEqualTo: queryText)
        .where('detail', isLessThan: '$queryText\uf8ff')
        .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      _hasMoreData = false;
      hasMoreData.value = false;
      return <Modele>[];
    }

    _lastDocument = querySnapshot.docs.last;
    return querySnapshot.docs
        .map((doc) => Modele.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> loadMore() async {
    final queryText = searchText.value.trim().toLowerCase();
    if (queryText.isEmpty || !_hasMoreData || isLoadingMore.value) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final page = await _fetchNextPage(queryText);
      if (page.isNotEmpty) {
        final existingIds =
            results.map((m) => m.id).whereType<String>().toSet();
        final deduped = page.where((m) {
          final id = m.id;
          if (id == null || id.isEmpty) return false;
          if (existingIds.contains(id)) return false;
          existingIds.add(id);
          return true;
        });
        results.addAll(deduped);
        ModeleService().setCachedSearch(queryText, results);
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retrySearch() async {
    await _startFreshSearch();
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    searchController.dispose();
    super.onClose();
  }
}
