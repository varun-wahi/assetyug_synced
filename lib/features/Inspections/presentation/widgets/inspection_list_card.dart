import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';
import 'status_badge.dart';

/// One row in "All inspections": template/asset name + status badge,
/// then a "Template · Customer · Location" line and a "Performer · Due date" line.
class InspectionListCard extends StatelessWidget {
  final InspectionSummary inspection;
  final VoidCallback? onTap;

  const InspectionListCard({
    super.key,
    required this.inspection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dueLabel = DateFormat('MM/dd/yyyy').format(inspection.dueDate);
    final subtitleParts = [
      inspection.templateName,
      if (inspection.customer != null && inspection.customer!.isNotEmpty)
        inspection.customer!,
      inspection.location,
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: inspection.status.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    inspection.assetName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: inspection.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitleParts.join(' · '),
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 2),
            Text(
              '${inspection.performedBy} · Due $dueLabel',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Border color of each card matches its status, like the screenshot
/// (green border for completed, blue for ongoing, etc).
extension _InspectionStatusBorder on InspectionStatus {
  Color get borderColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFFFBD38D);
      case InspectionStatus.ongoing:
        return const Color(0xFFBFDBFE);
      case InspectionStatus.completed:
        return const Color(0xFFBBD8A3);
    }
  }
}
