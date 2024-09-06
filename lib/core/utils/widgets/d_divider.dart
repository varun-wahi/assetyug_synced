
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DDivider extends StatelessWidget {
  final double gap;
  final double thickness;
  final Color color;


  const DDivider({
    Key? key,
    this.gap = dGap,
    this.thickness =0.2,
    this.color = darkGrey //Default gap of 10.0

    // required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: gap,
      thickness: thickness,
      color: color,
    );
  }
}
