import 'package:intl/intl.dart';

/// Sort field options for the inspections detailed filter API.
const List<MapEntry<String, String>> kInspectionSortFields = [
  MapEntry('Created Date', 'createdAt'),
  MapEntry('Status', 'status'),
  MapEntry('Inspection Name', 'assetCategoryInspectionName'),
  MapEntry('Performed By', 'actionPerformedBy'),
  MapEntry('Due Date', 'inspectionDueDate'),
];

/// Sort direction options.
const List<MapEntry<String, String>> kInspectionSortDirections = [
  MapEntry('Newest First (DESC)', 'DESC'),
  MapEntry('Oldest First (ASC)', 'ASC'),
];

/// Fixed status options shown in title case; payload uses UPPER_SNAKE.
const List<String> kInspectionStatusOptions = [
  'All',
  'Pending',
  'Completed',
  'Failed',
  'Cancelled',
  'In Progress',
  'Ongoing',
];

String inspectionStatusToApi(String? uiStatus) {
  if (uiStatus == null || uiStatus.trim().isEmpty || uiStatus == 'All') {
    return '';
  }
  return uiStatus.trim().toUpperCase().replaceAll(' ', '_');
}

String? inspectionSortFieldLabel(String apiValue) {
  for (final entry in kInspectionSortFields) {
    if (entry.value == apiValue) return entry.key;
  }
  return null;
}

String? inspectionSortDirectionLabel(String apiValue) {
  for (final entry in kInspectionSortDirections) {
    if (entry.value == apiValue) return entry.key;
  }
  return null;
}

class InspectionFilterData {
  final String? inspectionName;
  final String? status; // UI title-case; "All" means unset
  final String? performedBy;
  final String sortField;
  final String sortDirection;

  final String? customerId;
  final String? customerName;
  final String? customerCategory;

  final String? assetName;
  final String? assetCustomer;
  final String? serialNumber;
  final String? assetId;
  final String? assetCategory;
  final String? assetLocation; // location:{id} or bin:{id}
  final String? assetLocationLabel;

  final DateTime? createdDateFrom;
  final DateTime? createdDateTo;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;

  const InspectionFilterData({
    this.inspectionName,
    this.status,
    this.performedBy,
    this.sortField = 'createdAt',
    this.sortDirection = 'DESC',
    this.customerId,
    this.customerName,
    this.customerCategory,
    this.assetName,
    this.assetCustomer,
    this.serialNumber,
    this.assetId,
    this.assetCategory,
    this.assetLocation,
    this.assetLocationLabel,
    this.createdDateFrom,
    this.createdDateTo,
    this.dueDateFrom,
    this.dueDateTo,
  });

  static const InspectionFilterData empty = InspectionFilterData();

  InspectionFilterData copyWith({
    String? inspectionName,
    String? status,
    String? performedBy,
    String? sortField,
    String? sortDirection,
    String? customerId,
    String? customerName,
    String? customerCategory,
    String? assetName,
    String? assetCustomer,
    String? serialNumber,
    String? assetId,
    String? assetCategory,
    String? assetLocation,
    String? assetLocationLabel,
    DateTime? createdDateFrom,
    DateTime? createdDateTo,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool clearInspectionName = false,
    bool clearStatus = false,
    bool clearPerformedBy = false,
    bool clearCustomer = false,
    bool clearCustomerCategory = false,
    bool clearAssetName = false,
    bool clearAssetCustomer = false,
    bool clearSerialNumber = false,
    bool clearAssetId = false,
    bool clearAssetCategory = false,
    bool clearAssetLocation = false,
    bool clearCreatedRange = false,
    bool clearDueRange = false,
  }) {
    return InspectionFilterData(
      inspectionName:
          clearInspectionName ? null : (inspectionName ?? this.inspectionName),
      status: clearStatus ? null : (status ?? this.status),
      performedBy: clearPerformedBy ? null : (performedBy ?? this.performedBy),
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerCategory: clearCustomerCategory
          ? null
          : (customerCategory ?? this.customerCategory),
      assetName: clearAssetName ? null : (assetName ?? this.assetName),
      assetCustomer:
          clearAssetCustomer ? null : (assetCustomer ?? this.assetCustomer),
      serialNumber:
          clearSerialNumber ? null : (serialNumber ?? this.serialNumber),
      assetId: clearAssetId ? null : (assetId ?? this.assetId),
      assetCategory:
          clearAssetCategory ? null : (assetCategory ?? this.assetCategory),
      assetLocation:
          clearAssetLocation ? null : (assetLocation ?? this.assetLocation),
      assetLocationLabel: clearAssetLocation
          ? null
          : (assetLocationLabel ?? this.assetLocationLabel),
      createdDateFrom:
          clearCreatedRange ? null : (createdDateFrom ?? this.createdDateFrom),
      createdDateTo:
          clearCreatedRange ? null : (createdDateTo ?? this.createdDateTo),
      dueDateFrom: clearDueRange ? null : (dueDateFrom ?? this.dueDateFrom),
      dueDateTo: clearDueRange ? null : (dueDateTo ?? this.dueDateTo),
    );
  }

  bool get hasNonDefaultSort =>
      sortField != 'createdAt' || sortDirection != 'DESC';

  /// Count of active filters for the badge (excludes default sort).
  int get activeCount {
    var count = 0;
    if (_filled(inspectionName)) count++;
    if (_filled(status) && status != 'All') count++;
    if (_filled(performedBy)) count++;
    if (_filled(customerId) || _filled(customerName)) count++;
    if (_filled(customerCategory)) count++;
    if (_filled(assetName)) count++;
    if (_filled(assetCustomer)) count++;
    if (_filled(serialNumber)) count++;
    if (_filled(assetId)) count++;
    if (_filled(assetCategory)) count++;
    if (_filled(assetLocation)) count++;
    if (createdDateFrom != null || createdDateTo != null) count++;
    if (dueDateFrom != null || dueDateTo != null) count++;
    if (hasNonDefaultSort) count++;
    return count;
  }

  bool get hasActiveFilters => activeCount > 0;

  /// Builds the POST body for `/inspection/detailed/{companyId}`.
  /// Empty values are omitted. Always includes pagination + sort.
  Map<String, dynamic> toPayload({
    required int pageNumber,
    required int pageSize,
  }) {
    final payload = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sortField': sortField.isEmpty ? 'createdAt' : sortField,
      'sortDirection': sortDirection.isEmpty ? 'DESC' : sortDirection,
    };

    void put(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        payload[key] = trimmed;
      }
    }

    put('inspectionName', inspectionName);
    put('status', inspectionStatusToApi(status));
    put('performedBy', performedBy);
    put('customerId', customerId);
    put('customerCategory', customerCategory);
    put('assetName', assetName);
    put('assetCustomer', assetCustomer);
    put('serialNumber', serialNumber);
    put('assetId', assetId);
    put('assetCategory', assetCategory);
    put('assetLocation', assetLocation);

    final dateFmt = DateFormat('yyyy-MM-dd');
    if (createdDateFrom != null) {
      payload['createdDateFrom'] = dateFmt.format(createdDateFrom!);
    }
    if (createdDateTo != null) {
      payload['createdDateTo'] = dateFmt.format(createdDateTo!);
    }
    if (dueDateFrom != null) {
      payload['dueDateFrom'] = dateFmt.format(dueDateFrom!);
    }
    if (dueDateTo != null) {
      payload['dueDateTo'] = dateFmt.format(dueDateTo!);
    }

    return payload;
  }

  static bool _filled(String? value) =>
      value != null && value.trim().isNotEmpty;
}
