// lib/core/utils/widgets/custom_field_widget.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'd_text_field.dart';

class CustomFieldWidget extends StatelessWidget {
  final String fieldName;
  final String fieldType;
  final TextEditingController controller;
  final bool showClearButton;
  final bool isMandatory; // 👈 add thi

  const CustomFieldWidget({
    super.key,
    required this.fieldName,
    required this.fieldType,
    required this.controller,
    this.showClearButton = false,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fieldType == "date") {
      return _buildDateField(context);
    }
    return _buildTextField();
  }

  Widget _buildDateField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              }
            },
            child: AbsorbPointer(
              child: DTextField(
                icon: const Icon(Icons.calendar_today),
                hintText: fieldName,
                isMandatory: isMandatory,
                controller: controller,
                textInputType: TextInputType.none,
              ),
            ),
          ),
        ),
        if (showClearButton)
          IconButton(
            icon: const Icon(Icons.clear, color: darkGrey),
            onPressed: () => controller.clear(),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return Row(
      children: [
        Expanded(
          child: DTextField(
            icon: const Icon(Icons.tune),
            hintText: fieldName,
            isMandatory: isMandatory,
            controller: controller,
            textInputType: fieldType == "number"
                ? TextInputType.number
                : TextInputType.text,
          ),
        ),
        if (showClearButton)
          IconButton(
            icon: const Icon(Icons.clear, color: darkGrey),
            onPressed: () => controller.clear(),
          ),
      ],
    );
  }
}
