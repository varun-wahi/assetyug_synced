import 'package:flutter/material.dart';

import 'form_field_decoration.dart';

class DTextField extends StatelessWidget {
  final Icon? icon;
  final String hintText;
  final String? text;
  final TextInputType textInputType;
  final bool? enabled;
  final TextAlign? textAlignment;
  final bool hasLabel;
  final int maxLines;
  final EdgeInsetsGeometry? padding;
  final TextEditingController? controller;
  final bool isMandatory;
  final FocusNode? focusNode;
  final bool autofocus;

  const DTextField({
    super.key,
    this.textInputType = TextInputType.text,
    this.icon,
    required this.hintText,
    this.enabled,
    this.text,
    this.hasLabel = false,
    this.maxLines = 1,
    this.isMandatory = false,
    this.padding,
    this.controller,
    this.textAlignment,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final showAsLabel = hasLabel || isMandatory;

    return Padding(
      padding: padding ?? FormFieldStyles.padding,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        maxLines: maxLines,
        keyboardType: textInputType,
        textAlign: textAlignment ?? TextAlign.start,
        style: FormFieldStyles.textStyle,
        cursorColor: FormFieldStyles.textStyle.color,
        decoration: FormFieldStyles.decoration(
          enabled: enabled ?? true,
          prefixIcon: icon,
          label: showAsLabel
              ? FormFieldStyles.mandatoryLabel(
                  hintText,
                  isMandatory: isMandatory,
                )
              : null,
          hintText: showAsLabel ? null : hintText,
        ),
      ),
    );
  }
}
