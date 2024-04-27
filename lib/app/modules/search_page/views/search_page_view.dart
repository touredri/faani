import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = Get.put(SearchPageController());
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: controller.searchController,
            decoration: const InputDecoration(
              // hintText: 'Search',
              labelText: 'search',
              prefix: Icon(Icons.search, color: Colors.black),
              suffix: Icon(Icons.close, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Center(
              child: Text('Item $index'),
            ),
          );
        },
      ),
    );
  }
}
