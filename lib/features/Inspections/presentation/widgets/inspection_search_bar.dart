import 'package:flutter/material.dart';

/// The "Search inspections..." text field paired with a "Filters" button.
class InspectionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFiltersTap;
  final int activeFilterCount;

  const InspectionSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFiltersTap,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by asset name...',
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            OutlinedButton.icon(
              onPressed: onFiltersTap,
              icon: const Icon(Icons.tune, size: 18, color: Color(0xFF374151)),
              label: const Text(
                'Filters',
                style: TextStyle(
                    color: Color(0xFF374151), fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: activeFilterCount > 0
                    ? const Color(0xFFE8EEF5)
                    : const Color(0xFFF3F4F6),
                side: BorderSide.none,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B1E40),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    activeFilterCount > 9 ? '9+' : '$activeFilterCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
