import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../../../config/theme/text_styles.dart';
import 'd_gap.dart';

class DSelectedFilterItem extends StatelessWidget {
  final bool isDropdown;
  final String title;
  final VoidCallback onPressed;
  final String selectedOption;
  const DSelectedFilterItem({
    super.key,
    required this.isDropdown,
    required this.title,
    required this.onPressed,
    required this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    
    final bool isSort;
    isSort = (title == "Sort by") ? true : false;

    return Container(
      padding: const EdgeInsets.only(left: dPadding * 2),
      // width: 110,
      decoration: BoxDecoration(
        color: isSort ? tWhite : tPrimary,
        borderRadius: BorderRadius.circular(dBorderRadius),
        border: Border.all(width: 0.6, color: tPrimary)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: body(
                size: 13,
                color: isSort ? tBlack : tWhite),
          ),
          Text(selectedOption),
          // DGap(vertical: false),
          IconButton(
            color: isSort ? tBlack : tWhite,
            onPressed: onPressed,
            icon: isDropdown
                ? const Icon(Icons.keyboard_arrow_down)
                : const Icon(Icons.close),
            iconSize: 13,
          )
        ],
      ),
    );
  }
}
