// lib/core/models/custom_field_model.dart

class CustomField {
  final String id;
  final String name;
  final String type;
  final bool mandatory;
  final String email;
  final int companyId;

  CustomField({
    required this.name,
    required this.type,
    this.id = '',
    this.mandatory = false,
    this.email = '',
    this.companyId = 0,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        mandatory: json['mandatory'] ?? json['show'] ?? false,
        email: json['email']?.toString() ?? '',
        companyId: json['companyId'] is int
            ? json['companyId']
            : int.tryParse(json['companyId']?.toString() ?? '') ?? 0,
      );
}

// Extends CustomField so it's a drop-in wherever CustomField is expected
class CustomFieldWithValue extends CustomField {
  final String value;
  final String assetId;

  CustomFieldWithValue({
    required super.name,
    required super.type,
    required this.value,
    required this.assetId,
    super.id,
    super.mandatory,
    super.email,
    super.companyId,
  });

  Map<String, dynamic> toUpdateJson(String newValue) => {
        'id': id,
        'email': email,
        'name': name,
        'value': newValue,
        'assetId': assetId,
        'type': type,
        'companyId': companyId,
      };

  factory CustomFieldWithValue.fromExtraFieldJson(Map<String, dynamic> json) =>
      CustomFieldWithValue(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        assetId: json['assetId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        value: json['value']?.toString() ?? '—',
        mandatory: json['mandatory'] ?? json['show'] ?? false,
        email: json['email']?.toString() ?? '',
        companyId: json['companyId'] is int
            ? json['companyId']
            : int.tryParse(json['companyId']?.toString() ?? '') ?? 0,
      );
}
