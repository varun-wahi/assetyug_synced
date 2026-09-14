import 'package:flutter/material.dart';

import 'form_field_decoration.dart';

class DDropdown extends StatefulWidget {
  final String label;
  final List<DropdownMenuItem> items;
  final bool isMandatory;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<dynamic> onChanged;
  final dynamic value;

  const DDropdown({
    super.key,
    required this.label,
    required this.items,
    this.isMandatory = false,
    required this.onChanged,
    this.padding,
    this.value,
  });

  @override
  State<DDropdown> createState() => DDropdownState();
}

class DDropdownState extends State<DDropdown> {
  dynamic selectedOption;

  void clearDropdown() {
    setState(() {
      selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? FormFieldStyles.padding,
      child: DropdownButtonFormField(
        value: widget.value,
        style: FormFieldStyles.textStyle,
        isExpanded: true,
        decoration: FormFieldStyles.decoration(
          label: FormFieldStyles.mandatoryLabel(
            widget.label,
            isMandatory: widget.isMandatory,
          ),
        ),
        items: widget.items,
        onChanged: (option) {
          widget.onChanged(option);
        },
      ),
    );
  }
}
