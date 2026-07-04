import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';

/// Small rounded pill showing an [InspectionStatus]. Used in both the
/// list cards and the detail header so the color logic lives in one place.
class StatusBadge extends StatelessWidget {
  final InspectionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.foregroundColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
