import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

Padding buildCustomTextField(
    //ADD MAX SIZE OPTION
    String label,
    TextInputType type,
    TextEditingController controller,
    bool isMandatory,
    {bool autofocus = false, FocusNode? focusNode}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: TextFormField(
      style: const TextStyle(color: tBlack),
      cursorColor: tBlack,
      autofocus: autofocus,
      focusNode: focusNode,
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
    ),
  );
}
