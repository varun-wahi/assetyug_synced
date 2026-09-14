import 'package:flutter/material.dart';

/// Status of an inspection. Drives badge color + label everywhere it's used.
enum InspectionStatus { pending, cancelled, completed, other }

InspectionStatus inspectionStatusFromApi(String? raw) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'COMPLETED':
      return InspectionStatus.completed;
    case 'CANCELLED':
    case 'CANCELED':
      return InspectionStatus.cancelled;
    case 'PENDING':
      return InspectionStatus.pending;
    default:
      return InspectionStatus.other;
  }
}

String inspectionStatusLabelFromApi(String? raw) {
  final status = inspectionStatusFromApi(raw);
  if (status != InspectionStatus.other) return status.label;
  final value = (raw ?? '').trim();
  if (value.isEmpty) return 'Other';
  return value
      .toLowerCase()
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

DateTime? parseInspectionDate(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int parseInspectionCount(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

extension InspectionStatusX on InspectionStatus {
  String get label {
    switch (this) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.cancelled:
        return 'Cancelled';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.other:
        return 'Other';
    }
  }

  String get subtitle {
    switch (this) {
      case InspectionStatus.pending:
        return 'Awaiting action';
      case InspectionStatus.cancelled:
        return 'Cancelled inspections';
      case InspectionStatus.completed:
        return 'Finished inspections';
      case InspectionStatus.other:
        return 'Other inspections';
    }
  }

  IconData get icon {
    switch (this) {
      case InspectionStatus.pending:
        return Icons.access_time_rounded;
      case InspectionStatus.cancelled:
        return Icons.cancel_outlined;
      case InspectionStatus.completed:
        return Icons.check_rounded;
      case InspectionStatus.other:
        return Icons.info_outline;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFFFDECC8);
      case InspectionStatus.cancelled:
        return const Color(0xFFFEE2E2);
      case InspectionStatus.completed:
        return const Color(0xFFDDEAD2);
      case InspectionStatus.other:
        return const Color(0xFFE5E7EB);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFF8A5A14);
      case InspectionStatus.cancelled:
        return const Color(0xFFB91C1C);
      case InspectionStatus.completed:
        return const Color(0xFF3A6B23);
      case InspectionStatus.other:
        return const Color(0xFF374151);
    }
  }

  Color get borderColor {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFFFBD38D);
      case InspectionStatus.cancelled:
        return const Color(0xFFFECACA);
      case InspectionStatus.completed:
        return const Color(0xFFBBD8A3);
      case InspectionStatus.other:
        return const Color(0xFFD1D5DB);
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

  factory InspectionStep.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? '').toString().toUpperCase();
    final type = switch (typeRaw) {
      'CHECKBOX' => InspectionStepType.checkbox,
      'NUMBER' => InspectionStepType.number,
      _ => InspectionStepType.text,
    };
    return InspectionStep(
      label: (json['name'] ?? json['label'] ?? '').toString(),
      type: type,
      value: (json['value'] ?? '').toString(),
    );
  }
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
  final String serialNumber;
  final String category;
  final String notes;
  final DateTime createdAt;
  final List<InspectionStep> steps;

  InspectionSummary({
    required this.id,
    required this.assetName,
    required this.templateName,
    this.customer,
    required this.location,
    required this.performedBy,
    required this.dueDate,
    required this.status,
    this.serialNumber = '--',
    this.category = '--',
    this.notes = '',
    DateTime? createdAt,
    this.steps = const [],
  }) : createdAt = createdAt ?? dueDate;

  factory InspectionSummary.fromDetailedJson(Map<String, dynamic> json) {
    final instance = json['inspectionInstance'] is Map
        ? Map<String, dynamic>.from(json['inspectionInstance'] as Map)
        : <String, dynamic>{};
    final createdAt = parseInspectionDate(instance['createdAt']) ??
        DateTime.now();
    final dueDate = parseInspectionDate(
          instance['dueDate'] ?? instance['inspectionDueDate'],
        ) ??
        createdAt;
    final stepValues = instance['stepValues'] is List
        ? (instance['stepValues'] as List)
            .whereType<Map>()
            .map((step) => InspectionStep.fromJson(Map<String, dynamic>.from(step)))
            .toList()
        : <InspectionStep>[];

    return InspectionSummary(
      id: (instance['id'] ?? '').toString(),
      assetName: (json['assetName'] ?? 'Unnamed asset').toString(),
      templateName: (instance['assetCategoryInspectionName'] ??
              (instance['selectedItemList'] is List &&
                      (instance['selectedItemList'] as List).isNotEmpty
                  ? (instance['selectedItemList'] as List).first['name']
                  : 'Inspection'))
          .toString(),
      customer: (json['customerName'] ?? '').toString(),
      location: (json['assetLocation'] ?? '').toString(),
      performedBy: (instance['actionPerformedBy'] ??
              instance['createdBy'] ??
              'Unassigned')
          .toString(),
      dueDate: dueDate,
      status: inspectionStatusFromApi(instance['status']?.toString()),
      serialNumber: (json['serialNumber'] ?? '--').toString(),
      category: (json['assetCategory'] ?? '--').toString(),
      notes: (instance['notes'] ?? '').toString(),
      createdAt: createdAt,
      steps: stepValues,
    );
  }

  InspectionDetail toDetail() {
    return InspectionDetail(
      templateName: templateName,
      status: status,
      assetName: assetName,
      serialNumber: serialNumber.isEmpty ? '--' : serialNumber,
      category: category.isEmpty ? '--' : category,
      customer: (customer == null || customer!.isEmpty) ? 'Unassigned' : customer!,
      location: location.isEmpty ? '--' : location,
      performedBy: performedBy,
      createdAt: createdAt,
      dueAt: dueDate,
      steps: steps,
      notes: notes.isEmpty ? '--' : notes,
    );
  }
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

class InspectionStatusCount {
  final InspectionStatus status;
  final String label;
  final int count;

  const InspectionStatusCount({
    required this.status,
    required this.label,
    required this.count,
  });
}

/// Aggregate counts + per-employee breakdown for the top summary cards.
class InspectionStats {
  final int total;
  final List<InspectionStatusCount> statusCounts;
  final List<EmployeeInspectionCount> byEmployee;

  const InspectionStats({
    required this.total,
    this.statusCounts = const [],
    required this.byEmployee,
  });

  List<InspectionStatusCount> get visibleStatusCounts =>
      statusCounts.where((item) => item.count > 0).toList();

  factory InspectionStats.fromApi({
    required Map<String, dynamic> statusCountJson,
    List<EmployeeInspectionCount> byEmployee = const [],
  }) {
    final counts = statusCountJson['statusCounts'] is List
        ? (statusCountJson['statusCounts'] as List).whereType<Map>()
        : const Iterable<Map>.empty();

    final statusCounts = counts.map((item) {
      final map = Map<String, dynamic>.from(item);
      final rawStatus = map['status']?.toString();
      return InspectionStatusCount(
        status: inspectionStatusFromApi(rawStatus),
        label: inspectionStatusLabelFromApi(rawStatus),
        count: parseInspectionCount(map['count']),
      );
    }).toList()
      ..sort((a, b) => a.status.index.compareTo(b.status.index));

    final reportedTotal =
        parseInspectionCount(statusCountJson['totalInspections']);
    final summed =
        statusCounts.fold<int>(0, (sum, item) => sum + item.count);

    return InspectionStats(
      total: reportedTotal > 0 ? reportedTotal : summed,
      statusCounts: statusCounts,
      byEmployee: byEmployee,
    );
  }
}

class EmployeeInspectionCount {
  final String name;
  final int count;

  const EmployeeInspectionCount({required this.name, required this.count});

  factory EmployeeInspectionCount.fromJson(Map<String, dynamic> json) {
    return EmployeeInspectionCount(
      name: (json['performedBy'] ?? json['name'] ?? 'Unassigned').toString(),
      count: parseInspectionCount(json['count']),
    );
  }
}
