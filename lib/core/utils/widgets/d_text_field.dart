import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';

class DTextField extends StatelessWidget {
  final Icon? icon;
  final String hintText;
  final String? text;
  final TextInputType textInputType;
  final bool? enabled;
  final TextAlign? textAlignment;
  final bool hasLabel;
  final int maxLines;
  final double padding;
  final TextEditingController? controller;
  final bool isMandatory;

  const DTextField({
    super.key,
    this.textInputType = TextInputType.text, //Default gap of 10.0
    this.icon,
    required this.hintText, //default set to vertical
    this.enabled,
    this.text,
    this.hasLabel = false,
    this.maxLines = 1,
    this.isMandatory = false,
    this.padding = 8.0,
    this.controller,
    this.textAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: textInputType,
        textAlign: textAlignment ?? TextAlign.start,
        decoration: InputDecoration(
          enabled: enabled ?? true,
          prefixIcon: icon,
          contentPadding: const EdgeInsets.all(dPadding * 2),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: textColor1),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: tPrimary),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          label: hasLabel
              ? Text(hintText)
              : isMandatory // 👈 show asterisk
                  ? RichText(
                      text: TextSpan(
                        text: hintText,
                        style: const TextStyle(color: textColor1),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    )
                  : null,
          hintText: !hasLabel && !isMandatory ? hintText : null,
        ),
      ),
    );
  }
}
