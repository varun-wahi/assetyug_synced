import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';


    TextFormField buildCustomTextField(
      //ADD MAX SIZE OPTION
      String label,
      TextInputType type,
      TextEditingController controller,
      bool isMandatory) {
    return TextFormField(
      style: const TextStyle(color: tBlack),
      cursorColor: tBlack,
      decoration: InputDecoration(
        labelText: isMandatory ? "$label *" : label,
        labelStyle: const TextStyle(color: tBlack),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: tBlack)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: tBlack)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: tRed)),
      ),
      keyboardType: type,
      controller: controller,
    );
  }