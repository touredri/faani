import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmer() {
  return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          );
}