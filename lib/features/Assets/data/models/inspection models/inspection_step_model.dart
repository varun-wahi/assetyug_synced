class InspectionStepModel {
  final String? id;
  final int? stepNumber;
  final String name;
  final String type; // TEXT, NUMBER, CHECKBOX, IMAGE
  final String? inspectionStepId;
  final String? inspectionName;
  final dynamic value;

  InspectionStepModel({
    this.id,
    this.stepNumber,
    required this.name,
    required this.type,
    this.inspectionStepId,
    this.inspectionName,
    this.value,
  });

  factory InspectionStepModel.fromJson(Map<String, dynamic> json) {
    return InspectionStepModel(
      id: json['id'],
      stepNumber: json['stepNumber'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'TEXT',
      inspectionStepId: json['inspectionStepId'],
      inspectionName: json['inspectionName'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepNumber': stepNumber,
      'name': name,
      'type': type,
      'inspectionStepId': inspectionStepId,
      'inspectionName': inspectionName,
      'value': value,
    };
  }

  InspectionStepModel copyWith({
    String? id,
    int? stepNumber,
    String? name,
    String? type,
    String? inspectionStepId,
    String? inspectionName,
    dynamic value,
  }) {
    return InspectionStepModel(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      name: name ?? this.name,
      type: type ?? this.type,
      inspectionStepId: inspectionStepId ?? this.inspectionStepId,
      inspectionName: inspectionName ?? this.inspectionName,
      value: value ?? this.value,
    );
  }
}