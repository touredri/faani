import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

TimelineTile buildTimelineTile({
  required IconIndicator indicator,
  required String title,
  required Widget child,
  bool isLast = false,
}) {
  return TimelineTile(
    alignment: TimelineAlign.manual,
    lineXY: 0.4,
    beforeLineStyle:
        LineStyle(color: Colors.white.withOpacity(0.7), thickness: 5),
    indicatorStyle: IndicatorStyle(
      indicatorXY: 0.4,
      drawGap: true,
      width: 30,
      height: 30,
      indicator: indicator,
    ),
    isLast: isLast,
    startChild: Center(
      child: Container(
        alignment: const Alignment(0.0, -0.50),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    ),
    // ),
    endChild: Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: child,
    ),
  );
}

class IconIndicator extends StatelessWidget {
  const IconIndicator({
    super.key,
    required this.iconData,
  });

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: Icon(
                iconData,
                size: 30,
                color: const Color(0xFF9E3773).withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
