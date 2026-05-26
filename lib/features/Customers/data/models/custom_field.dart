class CustomerCustomField {
  final String id;
  final String name;
  final String type;
  final bool mandatory;

  CustomerCustomField({required this.id, required this.name, required this.type, required this.mandatory});

  factory CustomerCustomField.fromJson(Map<String, dynamic> json) {
    return CustomerCustomField(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      mandatory: json['mandatory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'mandatory': mandatory,
      };
}
