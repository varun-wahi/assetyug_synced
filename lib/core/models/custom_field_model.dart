// lib/core/models/custom_field_model.dart

class CustomField {
  final String id;
  final String name;
  final String type;
  final bool mandatory;
  final bool show;
  final bool isUnique;
  final String email;
  final int companyId;

  CustomField({
    required this.name,
    required this.type,
    this.id = '',
    this.mandatory = false,
    this.show = false,
    this.isUnique = false,
    this.email = '',
    this.companyId = 0,
  });

  CustomField copyWith({
    String? id,
    String? name,
    String? type,
    bool? mandatory,
    bool? show,
    bool? isUnique,
    String? email,
    int? companyId,
  }) {
    return CustomField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      mandatory: mandatory ?? this.mandatory,
      show: show ?? this.show,
      isUnique: isUnique ?? this.isUnique,
      email: email ?? this.email,
      companyId: companyId ?? this.companyId,
    );
  }

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id']?.toString() ?? '',
        name: (json['name'] ?? json['fieldName'])?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        // Never treat `show` as `mandatory` — they are independent flags.
        mandatory: json['mandatory'] == true,
        show: json['show'] == true,
        isUnique: json['isUnique'] == true,
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
    super.show,
    super.isUnique,
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

  factory CustomFieldWithValue.fromExtraFieldJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    final value = rawValue == null ? '' : rawValue.toString();

    return CustomFieldWithValue(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Assets use assetId; customers use companyCustomerId / customerId.
      assetId: (json['assetId'] ??
              json['companyCustomerId'] ??
              json['customerId'])
          ?.toString() ??
          '',
      type: json['type']?.toString() ?? '',
      value: value,
      mandatory: json['mandatory'] == true,
      show: json['show'] == true,
      isUnique: json['isUnique'] == true,
      email: json['email']?.toString() ?? '',
      companyId: json['companyId'] is int
          ? json['companyId']
          : int.tryParse(json['companyId']?.toString() ?? '') ?? 0,
    );
  }
}
