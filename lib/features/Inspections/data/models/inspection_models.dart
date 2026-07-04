import 'package:flutter/material.dart';

/// Status of an inspection. Drives badge color + label everywhere it's used.
enum InspectionStatus { pending, ongoing, completed }

extension InspectionStatusX on InspectionStatus {
  String get label {
    switch (this) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.ongoing:
        return 'Ongoing';
      case InspectionStatus.completed:
        return 'Completed';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFFFDECC8);
      case InspectionStatus.ongoing:
        return const Color(0xFFDCEAFE);
      case InspectionStatus.completed:
        return const Color(0xFFDDEAD2);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFF8A5A14);
      case InspectionStatus.ongoing:
        return const Color(0xFF1D4ED8);
      case InspectionStatus.completed:
        return const Color(0xFF3A6B23);
    }
  }
}

/// A single step inside an inspection. How [value] is rendered depends on [type].
enum InspectionStepType { checkbox, number, text }

class InspectionStep {
  final String label;
  final InspectionStepType type;

  /// For checkbox steps: "true"/"false". For number/text steps: the raw value.
  final String value;

  const InspectionStep({
    required this.label,
    required this.type,
    required this.value,
  });
}

/// Summary item shown in the inspections list (the cards in image 1).
class InspectionSummary {
  final String id;
  final String assetName;
  final String templateName;
  final String? customer;
  final String location;
  final String performedBy;
  final DateTime dueDate;
  final InspectionStatus status;

  const InspectionSummary({
    required this.id,
    required this.assetName,
    required this.templateName,
    this.customer,
    required this.location,
    required this.performedBy,
    required this.dueDate,
    required this.status,
  });
}

/// Full detail payload shown in the detail widget (image 2).
class InspectionDetail {
  final String templateName;
  final InspectionStatus status;
  final String assetName;
  final String serialNumber;
  final String category;
  final String customer;
  final String location;
  final String performedBy;
  final DateTime createdAt;
  final DateTime dueAt;
  final List<InspectionStep> steps;
  final String notes;

  const InspectionDetail({
    required this.templateName,
    required this.status,
    required this.assetName,
    required this.serialNumber,
    required this.category,
    required this.customer,
    required this.location,
    required this.performedBy,
    required this.createdAt,
    required this.dueAt,
    required this.steps,
    required this.notes,
  });
}

/// Aggregate counts + per-employee breakdown for the top summary cards.
class InspectionStats {
  final int total;
  final int pending;
  final int ongoing;
  final int completed;
  final List<EmployeeInspectionCount> byEmployee;

  const InspectionStats({
    required this.total,
    required this.pending,
    required this.ongoing,
    required this.completed,
    required this.byEmployee,
  });
}

class EmployeeInspectionCount {
  final String name;
  final int count;

  const EmployeeInspectionCount({required this.name, required this.count});
}
