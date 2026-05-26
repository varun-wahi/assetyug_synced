// lib/core/utils/widgets/custom_fields_section.dart

import 'package:flutter/material.dart';
import '../../models/custom_field_model.dart';
import 'custom_field_widget.dart';

class CustomFieldsSection extends StatelessWidget {
  final List<CustomField> customFields;
  final Map<String, TextEditingController> controllers;
  final bool showClearButton;

  const CustomFieldsSection({
    super.key,
    required this.customFields,
    required this.controllers,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (customFields.isEmpty) return const SizedBox.shrink();

    return Column(
      children: customFields.map((field) {
        if (!controllers.containsKey(field.id)) {
          controllers[field.id] = TextEditingController();
        }
        return CustomFieldWidget(
          fieldName: field.name,
          fieldType: field.type,
          controller: controllers[field.id]!,
          showClearButton: showClearButton,
        );
      }).toList(),
    );
  }
}
