import 'package:flutter/material.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/config/theme/text_styles.dart';

import '../../data/models/inspection models/asset_inspection_instance__model.dart';

class InspectionInstanceCard extends StatelessWidget {
  final AssetInspectionInstanceModel instance;
  final VoidCallback? onTap;

  const InspectionInstanceCard({
    super.key,
    required this.instance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = instance.status == 'PENDING';
    final statusColor = isPending ? Colors.orange : Colors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(dPadding),
        decoration: BoxDecoration(
          color: tWhite,
          border: Border.all(width: D_BORDER_WIDTH, color: lighterGrey),
          borderRadius: BorderRadius.circular(dBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    instance.assetCategoryInspectionName.isNotEmpty
                        ? instance.assetCategoryInspectionName
                        : 'Inspection',
                    style: body(weight: FontWeight.w600, size: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    instance.status,
                    style: body(
                      weight: FontWeight.w600,
                      size: 12,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'By: ${instance.actionPerformedBy}',
              style: body(weight: FontWeight.w400, size: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${instance.createdAt}',
              style: body(weight: FontWeight.w400, size: 14, color: Colors.grey),
            ),
            if (instance.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${instance.notes}',
                style: body(weight: FontWeight.w400, size: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}