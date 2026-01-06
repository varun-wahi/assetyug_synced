
import 'inspection_step_model.dart';

class AssetInspectionInstanceModel {
  final String id;
  final String assetId;
  final int companyId;
  final String createdAt;
  final String updatedAt;
  final String actionPerformedBy;
  final String notes;
  final String status; // PENDING or COMPLETED
  final String assetCategoryInspectionId;
  final String assetCategoryInspectionName;
  final List<InspectionStepModel> stepValues;
  final List<InspectionTemplateData> inspectionTemplates;
  final List<SelectedItem> selectedItemList;

  AssetInspectionInstanceModel({
    required this.id,
    required this.assetId,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.actionPerformedBy,
    required this.notes,
    required this.status,
    required this.assetCategoryInspectionId,
    required this.assetCategoryInspectionName,
    required this.stepValues,
    required this.inspectionTemplates,
    required this.selectedItemList,
  });

  factory AssetInspectionInstanceModel.fromJson(Map<String, dynamic> json) {
    return AssetInspectionInstanceModel(
      id: json['id'] ?? '',
      assetId: json['assetId'] ?? '',
      companyId: json['companyId'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      actionPerformedBy: json['actionPerformedBy'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'PENDING',
      assetCategoryInspectionId: json['assetCategoryInspectionId'] ?? '',
      assetCategoryInspectionName: json['assetCategoryInspectionName'] ?? '',
      stepValues: (json['stepValues'] as List<dynamic>?)
              ?.map((step) => InspectionStepModel.fromJson(step))
              .toList() ??
          [],
      inspectionTemplates: (json['inspectionTemplates'] as List<dynamic>?)
              ?.map((template) => InspectionTemplateData.fromJson(template))
              .toList() ??
          [],
      selectedItemList: (json['selectedItemList'] as List<dynamic>?)
              ?.map((item) => SelectedItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'actionPerformedBy': actionPerformedBy,
      'notes': notes,
      'status': status,
      'assetCategoryInspectionId': assetCategoryInspectionId,
      'assetCategoryInspectionName': assetCategoryInspectionName,
      'stepValues': stepValues.map((step) => step.toJson()).toList(),
      'inspectionTemplates':
          inspectionTemplates.map((template) => template.toJson()).toList(),
      'selectedItemList': selectedItemList.map((item) => item.toJson()).toList(),
    };
  }
}

class InspectionTemplateData {
  final String? inspectionName;
  final List<InspectionStepModel> stepValues;

  InspectionTemplateData({
    this.inspectionName,
    required this.stepValues,
  });

  factory InspectionTemplateData.fromJson(Map<String, dynamic> json) {
    return InspectionTemplateData(
      inspectionName: json['inspectionName'],
      stepValues: (json['stepValues'] as List<dynamic>?)
              ?.map((step) => InspectionStepModel.fromJson(step))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectionName': inspectionName,
      'stepValues': stepValues.map((step) => step.toJson()).toList(),
    };
  }
}

class SelectedItem {
  final String id;
  final String? name;

  SelectedItem({
    required this.id,
    this.name,
  });

  factory SelectedItem.fromJson(Map<String, dynamic> json) {
    return SelectedItem(
      id: json['id'] ?? '',
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}