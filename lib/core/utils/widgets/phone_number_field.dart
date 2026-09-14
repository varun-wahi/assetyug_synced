import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart' as intl_countries;

import 'form_field_decoration.dart';

/// Reusable phone number input with country-aware formatting/validation.
///
/// Wraps `IntlPhoneField` so every form in the app (Add Customer, driver
/// forms, etc.) gets the same look and the same country-code + national
/// number formatting instead of a plain text field.
///
/// [onChanged] is called on every keystroke with the full number (including
/// dial code, e.g. "+1XXXXXXXXXX") and whether the package considers it a
/// valid number for the currently selected dial code.
///
/// Set [enableCountryPicker] to false when the country is already chosen
/// elsewhere on the form (e.g. an address "Country" dropdown) and shouldn't
/// also be pickable from here - the flag still shows, it's just not
/// tappable/changeable.
class PhoneNumberField extends StatelessWidget {
  final String label;
  final String initialCountryCode;
  final void Function(String completeNumber, bool isValid) onChanged;
  final String? initialValue;
  final bool enableCountryPicker;
  final bool isMandatory;
  final EdgeInsetsGeometry? padding;

  const PhoneNumberField({
    super.key,
    this.label = 'Phone',
    this.initialCountryCode = 'US',
    this.initialValue,
    required this.onChanged,
    this.enableCountryPicker = true,
    this.isMandatory = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // When the picker is disabled, restrict the selectable list to just the
    // current country - there's nothing else to pick, so the flag renders
    // but tapping it has nothing to change.
    final restrictedCountries = enableCountryPicker
        ? null
        : intl_countries.countries
            .where((c) => c.code == initialCountryCode)
            .toList();

    return Padding(
      padding: padding ?? FormFieldStyles.padding,
      child: IntlPhoneField(
        initialValue: initialValue,
        style: FormFieldStyles.textStyle,
        dropdownTextStyle: FormFieldStyles.textStyle,
        decoration: FormFieldStyles.decoration(
          label: FormFieldStyles.mandatoryLabel(
            label,
            isMandatory: isMandatory,
          ),
          counterText: '', // hides the "x/y" character counter
        ),
        initialCountryCode: initialCountryCode,
        disableLengthCheck: false,
        showDropdownIcon: enableCountryPicker,
        countries: restrictedCountries,
        onChanged: (phone) {
          onChanged(phone.completeNumber, phone.isValidNumber());
        },
      ),
    );
  }
}
