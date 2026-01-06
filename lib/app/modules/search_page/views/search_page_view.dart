import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SearchPageController());
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          controller.loadMore();
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onTextChange,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        labelText: 'Rechercher',
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        suffixIcon: Icon(Icons.close, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Modele>>(
                stream: controller.searchResultsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // else if (Get.find<HomeController>().isOnline.value ==
                  //     false) {
                  //   return const Center(child: Text('Pas d\'accès internet'));
                  // }
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            'Resultat: Le modèle que vous recherchez n\'a été trouvé, utliser d\'autre mot clé.'));
                  } else {
                    return customMansoryGridView(
                      2,
                      snapshot.data!.length,
                      (context, index) {
                        return buildCard(snapshot.data![index],
                            context: context);
                      },
                      scrollController: scrollController,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
