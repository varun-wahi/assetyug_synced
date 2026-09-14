import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';

/// Shared chrome for all form entry widgets (text, dropdown, phone, etc.).
///
/// Matches the advanced filter form / [DTextField] look so Add Asset,
/// Add Customer, filters, and custom fields stay visually consistent.
class FormFieldStyles {
  FormFieldStyles._();

  /// Outer spacing around every form control.
  static const EdgeInsets padding = EdgeInsets.all(dPadding);

  /// Inner text/control padding inside the outlined box.
  static const EdgeInsets contentPadding = EdgeInsets.all(dPadding * 2);

  static const double fontSize = 16.0;

  static TextStyle get textStyle => const TextStyle(
        color: tBlack,
        fontSize: fontSize,
      );

  static TextStyle get labelStyle => const TextStyle(
        color: textColor1,
        fontSize: fontSize,
      );

  static BorderRadius get borderRadius =>
      BorderRadius.circular(dBorderRadius);

  static OutlineInputBorder get enabledBorder => OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: textColor1),
      );

  static OutlineInputBorder get focusedBorder => OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: tPrimary),
      );

  static OutlineInputBorder get errorBorder => OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: tRed),
      );

  /// Standard [InputDecoration] for outlined form fields.
  static InputDecoration decoration({
    String? labelText,
    Widget? label,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
    String? counterText,
  }) {
    return InputDecoration(
      enabled: enabled,
      labelText: labelText,
      label: label,
      hintText: hintText,
      labelStyle: labelStyle,
      hintStyle: labelStyle.copyWith(color: textColor1.withOpacity(0.6)),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: counterText,
      contentPadding: contentPadding,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      disabledBorder: enabledBorder,
      border: enabledBorder,
    );
  }

  /// Label with optional red asterisk for mandatory fields.
  static Widget? mandatoryLabel(String text, {bool isMandatory = false}) {
    if (!isMandatory) return Text(text, style: labelStyle);
    return RichText(
      text: TextSpan(
        text: text,
        style: labelStyle,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
