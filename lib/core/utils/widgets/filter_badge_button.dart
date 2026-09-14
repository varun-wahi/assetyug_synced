import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

/// Filters button with white background matching the Sort by chip style,
/// plus an optional active-filter count badge.
class FilterBadgeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int activeFilterCount;
  final String label;

  const FilterBadgeButton({
    super.key,
    this.onPressed,
    this.activeFilterCount = 0,
    this.label = 'Filters',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.tune, size: 16, color: tBlack),
          label: Text(
            label,
            style: const TextStyle(
              color: tBlack,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: tWhite,
            foregroundColor: tBlack,
            side: const BorderSide(width: 0.6, color: tPrimary),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(dBorderRadius),
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
                color: tPrimary,
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
    );
  }
}
