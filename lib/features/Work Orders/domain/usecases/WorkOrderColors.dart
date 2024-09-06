import 'dart:ui';

import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class WorkOrderColors {
  static Color getColorForPriority(String priority) {
    switch (priority) {
      case "High":
        return tRed;
      case "Low":
        return Colors.yellow.shade800;
      case "Medium":
        return tOrange;
      default:
        return darkGrey; // Or any default color
    }
  }

  static Color getColorForStatus(String status) {
    switch (status) {
      case "Open":
        return tPurple;
      case "In Progress":
        return tGreen;
      case "On Hold":
        return tGreyLight;
      default:
        return darkGrey; // Or any default color
    }
  }

}
