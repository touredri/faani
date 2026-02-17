import 'package:faani/app/style/app_animations.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedSearchBar extends StatelessWidget {
  final TextEditingController textEditingController;
  final RxBool isSearching;
  final Function onSearch;
  final Color color;
  final GetxController? controller;
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
        final searching = isSearching.value;
        return AnimatedContainer(
          width: searching ? MediaQuery.sizeOf(context).width * 0.75 : 40,
          height: 40,
          duration: AppAnimations.normal,
          curve: Curves.easeInOut,
          child: ClipRect(
            child: TextField(
              controller: textEditingController,
              style: TextStyle(color: color),
              decoration: InputDecoration(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
                enabledBorder: searching
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: color),
                        borderRadius: AppRadius.radiusMd,
                      )
                    : InputBorder.none,
                focusedBorder: searching
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: color, width: 1.5),
                        borderRadius: AppRadius.radiusMd,
                      )
                    : InputBorder.none,
                hintText: 'Chercher',
                hintStyle: TextStyle(color: color.withValues(alpha: 0.6)),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  color: color,
                  icon: Icon(
                    searching ? Icons.close : Icons.search,
                    size: 24,
                  ),
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
