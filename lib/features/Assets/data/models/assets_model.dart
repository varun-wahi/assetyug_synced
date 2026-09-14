// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';

AssetsModel mongoDbModelFromJson(String str) =>
    AssetsModel.fromJson(json.decode(str));

String mongoDbModelToJson(AssetsModel data) => json.encode(data.toJson());

class AssetsModel {
  String? image;
  String? assetId; // Change this to String
  String companyId;
  String serialNumber;
  String location;
  String? id;
  String? email;
  String name;
  String category;
  String? customer;
  String customerId;
  String status;

  AssetsModel(
      {this.id,
      this.assetId,
      this.email,
      required this.name,
      required this.serialNumber,
      this.customer,
      required this.customerId,
      this.location = '',
      this.status = '',
      this.category = '',
      this.image,
      this.companyId = ''});

  /// Treats null, blank, and the literal "null" as missing.
  static String _orDefault(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }

  factory AssetsModel.fromJson(Map<String, dynamic> json) => AssetsModel(
        id: json["id"]?.toString(),
        email: _orDefault(json["email"], 'defaultemail@company.com'),
        name: _orDefault(json["name"], 'Unnamed Asset'),
        assetId: _orDefault(json["assetId"], '000'),
        serialNumber: _orDefault(json["serialNumber"], 'N/A'),
        customer: _orDefault(json["customer"], 'Unassigned'),
        customerId: _orDefault(json["customerId"], 'Unknown Customer ID'),
        // Prefer human-readable locationName from optimized filter response
        location: _orDefault(
          json["locationName"] ?? json["location"],
          'Unassigned',
        ),
        status: _orDefault(json["status"], 'Unassigned'),
        category: _orDefault(json["category"], 'Unassigned'),
        image: json["image"]?.toString(),
        companyId: _orDefault(json["companyId"], ''),
      );

  // Update toJson method as well
  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "assetId": assetId,
        "name": name,
        "serialNumber": serialNumber,
        "customer": customer,
        "customerId": customerId,
        "location": location,
        "status": status,
        "category": category,
        "image": image,
        "companyId": companyId,
      };
}
