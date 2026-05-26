class CustomField {
  final String id;
  final String name;
  final bool mandatory; // true for mandatory, false for show
  final String type; // e.g., 'number', 'text'
  final String email;
  final int companyId;

  CustomField({
    required this.id,
    required this.name,
    required this.mandatory,
    required this.type,
    required this.email,
    required this.companyId,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        id: json['id'] as String,
        name: json['name'] as String,
        mandatory: json['mandatory'] ?? json['show'] ?? false,
        type: json['type'] as String,
        email: json['email'] as String,
        companyId: json['companyId'] as int,
      );
}
