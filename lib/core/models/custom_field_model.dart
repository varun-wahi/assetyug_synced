// lib/core/models/custom_field.dart

class CustomField {
  final String id;
  final String name;
  final String type;
  final bool mandatory;
  final String email;
  final int companyId;

  CustomField({
    required this.id,
    required this.name,
    required this.type,
    required this.mandatory,
    required this.email,
    required this.companyId,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        mandatory: json['mandatory'] ?? json['show'] ?? false,
        email: json['email'] as String,
        companyId: json['companyId'] as int,
      );
}
