import 'package:flutter/material.dart';

import '../../../../core/utils/widgets/d_text_field.dart';

/// Thin wrapper kept for call-site compatibility.
/// Uses the shared [DTextField] / FormFieldStyles chrome.
Widget buildCustomTextField(
  String label,
  TextInputType type,
  TextEditingController controller,
  bool isMandatory, {
  bool autofocus = false,
  FocusNode? focusNode,
}) {
  return DTextField(
    hintText: label,
    textInputType: type,
    controller: controller,
    isMandatory: isMandatory,
    hasLabel: true,
    autofocus: autofocus,
    focusNode: focusNode,
  );
}
