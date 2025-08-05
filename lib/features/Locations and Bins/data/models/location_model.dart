class LocationModel {
  final String id;
  final int companyId;
  final String name;
  final String parentLocation;
  final String address;
  final String apartment;
  final String city;
  final String state;
  final String status;
  final dynamic zipCode;

  LocationModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.parentLocation,
    required this.address,
    required this.apartment,
    required this.city,
    required this.state,
    required this.status,
    this.zipCode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? 0,
      name: json['name'] ?? '',
      parentLocation: json['parentLocation'] ?? '',
      address: json['address'] ?? '',
      apartment: json['apartment'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      status: json['status'] ?? '',
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'parentLocation': parentLocation,
      'address': address,
      'apartment': apartment,
      'city': city,
      'state': state,
      'status': status,
      'zipCode': zipCode,
    };
  }
}