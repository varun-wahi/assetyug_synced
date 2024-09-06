    // List<String>
    import 'package:asset_yug_debugging/core/utils/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<DropdownMenuItem> assetFieldTypeMenuItems = const [
      DropdownMenuItem(
        value: "Text",
        child: Text("Text"),
      ),
      DropdownMenuItem(
        value: "Number",
        child: Text("Number"),
      ),

      DropdownMenuItem(
        value: "Checkbox",
        child: Text("Checkbox"),
      ),

      DropdownMenuItem(
        value: "Date",
        child: Text("Date"),
      ),
      


    ];


List<DropdownMenuItem> assetRequiredMenuItems = const [
      DropdownMenuItem(
        value: true,
        child: Text("Required"),
      ),
      DropdownMenuItem(
        value: false,
        child: Text("Not Required"),
      ),


    ];