import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedSearchBar extends StatelessWidget {
  final TextEditingController textEditingController;
  final RxBool isSearching;
  final Function onSearch;
  final Color color;
  final GetxController? controller; // Change this to accept null
  const AnimatedSearchBar({
    super.key,
    required this.textEditingController,
    required this.isSearching,
    required this.onSearch,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: 'search',
      init: controller,
      builder: (dynamic controller) {
        return AnimatedContainer(
          width: isSearching.value ? 220 : 35,
          height: 40,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ClipRect(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                // fillColor: Colors.white,
                border: InputBorder.none,
                disabledBorder: isSearching.value
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: color),
                      )
                    : InputBorder.none,
                enabledBorder: isSearching.value
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: color),
                      )
                    : InputBorder.none,
                focusedBorder: isSearching.value
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: color),
                      )
                    : InputBorder.none,
                labelText: 'Chercher',
                suffixIcon: IconButton(
                  padding: const EdgeInsets.all(0),
                  color: color,
                  icon: Icon(isSearching.value ? Icons.close : Icons.search,
                      size: 30),
                  onPressed: () => onSearch(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
