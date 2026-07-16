import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPageController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;
  final RxList<Modele> results = <Modele>[].obs;
  final RxList<Modele> discoveries = <Modele>[].obs;
  final RxList<Categorie> categories = <Categorie>[].obs;
  final RxList<String> recentQueries = <String>[].obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedGenreHabit = ''.obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isDiscovering = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  Worker? _searchDebounce;
  StreamSubscription<List<Categorie>>? _categorySubscription;
  static const int _pageSize = 12;
  static const String _recentQueriesKey = 'recent_search_queries';

  bool get hasActiveFilters =>
      selectedCategoryId.value.isNotEmpty ||
      selectedGenreHabit.value.isNotEmpty;

  void onTextChange(String text) => searchText.value = text;

  void setCategoryFilter(String? categoryId) {
    selectedCategoryId.value = categoryId ?? '';
    _startFreshSearch();
  }

  void setGenreFilter(String? genreHabit) {
    selectedGenreHabit.value = genreHabit ?? '';
    _startFreshSearch();
  }

  void clearFilters() {
    selectedCategoryId.value = '';
    selectedGenreHabit.value = '';
    _startFreshSearch();
  }

  @override
  void onInit() {
    super.onInit();
    _loadRecentQueries();
    _categorySubscription = CategorieService().getCategorie().listen(
          categories.assignAll,
          onError: (_, __) => categories.clear(),
        );
    _searchDebounce = debounce<String>(
      searchText,
      (_) => _startFreshSearch(),
      time: const Duration(milliseconds: 350),
    );
  }

  Future<void> _loadRecentQueries() async {
    final prefs = await SharedPreferences.getInstance();
    recentQueries.assignAll(
      prefs.getStringList(_recentQueriesKey) ?? <String>[],
    );
  }

  Future<void> _persistRecentQueries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentQueriesKey, recentQueries.toList());
  }

  Future<void> addRecentQuery(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    recentQueries
        .removeWhere((item) => item.toLowerCase() == normalized.toLowerCase());
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

  Future<void> loadDiscovery() async {
    if (isDiscovering.value) return;
    isDiscovering.value = true;
    hasError.value = false;
    try {
      final page = await ModeleService().searchDiscoverable(
        query: '',
        categoryId: selectedCategoryId.value,
        genreHabit: selectedGenreHabit.value,
      );
      discoveries.assignAll(page.items);
    } catch (error) {
      discoveries.clear();
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isDiscovering.value = false;
    }
  }

  Future<void> _startFreshSearch() async {
    final query = searchText.value.trim();
    _lastDocument = null;
    _hasMoreData = true;
    hasMoreData.value = true;
    hasError.value = false;
    errorMessage.value = '';
    results.clear();

    if (query.isEmpty) {
      if (hasActiveFilters) {
        await loadDiscovery();
      } else {
        discoveries.clear();
        isDiscovering.value = false;
      }
      return;
    }

    final cacheKey = _cacheKey(query);
    final cached = ModeleService().getCachedSearch(cacheKey);
    if (cached.isNotEmpty) {
      results.assignAll(cached);
      await addRecentQuery(query);
      _refreshSearchCacheInBackground(query);
      return;
    }

    isInitialLoading.value = true;
    try {
      final page = await _fetchNextPage(query);
      results.assignAll(page);
      ModeleService().setCachedSearch(cacheKey, results);
      await addRecentQuery(query);
    } catch (error) {
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> _refreshSearchCacheInBackground(String query) async {
    _lastDocument = null;
    _hasMoreData = true;
    try {
      final page = await _fetchNextPage(query);
      if (page.isNotEmpty) {
        results.assignAll(page);
        ModeleService().setCachedSearch(_cacheKey(query), results);
      }
    } catch (_) {
      // Cached results remain available when refresh fails.
    }
  }

  Future<List<Modele>> _fetchNextPage(String query) async {
    final page = await ModeleService().searchDiscoverable(
      query: query,
      categoryId: selectedCategoryId.value,
      genreHabit: selectedGenreHabit.value,
      startAfter: _lastDocument,
      pageSize: _pageSize,
    );
    _lastDocument = page.lastDocument;
    _hasMoreData = page.hasMoreData;
    hasMoreData.value = page.hasMoreData;
    return page.items;
  }

  Future<void> loadMore() async {
    final query = searchText.value.trim();
    if (query.isEmpty || !_hasMoreData || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final page = await _fetchNextPage(query);
      final ids =
          results.map((modele) => modele.id).whereType<String>().toSet();
      results.addAll(
          page.where((modele) => modele.id != null && ids.add(modele.id!)));
      ModeleService().setCachedSearch(_cacheKey(query), results);
    } catch (error) {
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retrySearch() => _startFreshSearch();

  String _cacheKey(String query) =>
      '$query|${selectedCategoryId.value}|${selectedGenreHabit.value}';

  @override
  void onClose() {
    _searchDebounce?.dispose();
    _categorySubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
