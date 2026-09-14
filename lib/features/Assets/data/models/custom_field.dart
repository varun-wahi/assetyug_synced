class CustomField {
  final String id;
  final String name;
  final bool mandatory;
  final bool show;
  final bool isUnique;
  final String type; // e.g., 'number', 'text'
  final String email;
  final int companyId;

  CustomField({
    required this.id,
    required this.name,
    required this.mandatory,
    this.show = false,
    this.isUnique = false,
    required this.type,
    required this.email,
    required this.companyId,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id']?.toString() ?? '',
        name: (json['name'] ?? json['fieldName'])?.toString() ?? '',
        // Never treat `show` as `mandatory` — they are independent flags.
        mandatory: json['mandatory'] == true,
        show: json['show'] == true,
        isUnique: json['isUnique'] == true,
        type: json['type']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        companyId: json['companyId'] is int
            ? json['companyId'] as int
            : int.tryParse(json['companyId']?.toString() ?? '') ?? 0,
      );
}
