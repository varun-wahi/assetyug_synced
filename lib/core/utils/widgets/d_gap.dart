import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DGap extends StatelessWidget {
  final double gap;
  final bool vertical;

  const DGap({
    Key? key,
    this.gap = dGap, //Default gap of 10.0
    this.vertical = true, //default set to vertical
    // required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: vertical ? gap : 0.0,
      width: vertical ? 0.0 : gap,
    );
  }
}
