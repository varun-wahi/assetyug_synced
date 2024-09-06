    // List<String>
    import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:flutter/material.dart';

List<DropdownMenuItem> assetStatusMenuItems = const [
      DropdownMenuItem(
        value: activeStatusString,
        child: Text(activeStatusString),
      ),
      DropdownMenuItem(
        value: inactiveStatusString,
        child: Text(inactiveStatusString),
      )
    ];