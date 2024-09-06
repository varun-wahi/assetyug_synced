
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

BoxDecoration dBoxDecoration({
  Color color = tWhite,
  double borderRadius = dBorderRadius,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(borderRadius),
    
  );
}
