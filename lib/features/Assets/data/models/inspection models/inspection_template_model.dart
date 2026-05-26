import 'inspection_step_model.dart';

class AssetInspectionTemplateModel {
  final String id;
  final String name;
  final String categoryName;
  final String categoryId;
  final int companyId;
  final List<InspectionStepModel> steps;
  final String status;

  AssetInspectionTemplateModel({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.categoryId,
    required this.companyId,
    required this.steps,
    required this.status,
  });

  factory AssetInspectionTemplateModel.fromJson(Map<String, dynamic> json) {
    final categoryList = json['categoryName'] as List<dynamic>?;

    return AssetInspectionTemplateModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',

      // FIX HERE
      categoryName: categoryList != null && categoryList.isNotEmpty
          ? categoryList.first['categoryName'] ?? ''
          : '',

      // FIX HERE
      categoryId: categoryList != null && categoryList.isNotEmpty
          ? categoryList.first['id'].toString()
          : '',

      companyId: json['companyId'] ?? 0,

      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => InspectionStepModel.fromJson(step))
              .toList() ??
          [],

      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'companyId': companyId,
      'steps': steps.map((step) => step.toJson()).toList(),
      'status': status,
    };
  }
}
