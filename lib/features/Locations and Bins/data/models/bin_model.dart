class BinModel {
  final String id;
  final dynamic locationId;
  final String locationName;
  final String binNumber;
  final String status;
  final int companyId;

  BinModel({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.binNumber,
    required this.status,
    required this.companyId,
  });

  factory BinModel.fromJson(Map<String, dynamic> json) {
    return BinModel(
      id: json['id'] ?? '',
      locationId: json['locationId'],
      locationName: json['locationName'] ?? '',
      binNumber: json['binNumber'] ?? '',
      status: json['status'] ?? '',
      companyId: json['companyId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'locationName': locationName,
      'binNumber': binNumber,
      'status': status,
      'companyId': companyId,
    };
  }
}