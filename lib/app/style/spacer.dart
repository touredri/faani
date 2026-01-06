import 'package:flutter/widgets.dart';

/// Lightweight replacement for `flutter_spacer`.
///
/// This project used `flutter_spacer` for `.hs` / `.ws` helpers, but the package
/// can throw `LateInitializationError` if its globals aren't initialized.
///
/// Here, `.hs` and `.ws` are implemented as *percentages* of the current screen
/// height/width (e.g. `2.hs` = 2% of screen height).
extension FaaniSpacerExtension on num {
  Widget get hs => _FaaniSpacer(axis: Axis.vertical, factor: toDouble());
  Widget get ws => _FaaniSpacer(axis: Axis.horizontal, factor: toDouble());
}

class _FaaniSpacer extends StatelessWidget {
  const _FaaniSpacer({
    required this.axis,
    required this.factor,
  });

  final Axis axis;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final unit = axis == Axis.vertical ? size.height : size.width;
    final value = unit * (factor / 100.0);

    return axis == Axis.vertical
        ? SizedBox(height: value)
        : SizedBox(width: value);
  }
}
