import 'package:flutter/material.dart';

/// The "Search inspections..." text field paired with a "Filters" button.
class InspectionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFiltersTap;

  const InspectionSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search inspections...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: onFiltersTap,
          icon: const Icon(Icons.tune, size: 18, color: Color(0xFF374151)),
          label: const Text(
            'Filters',
            style: TextStyle(
                color: Color(0xFF374151), fontWeight: FontWeight.w500),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF3F4F6),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
