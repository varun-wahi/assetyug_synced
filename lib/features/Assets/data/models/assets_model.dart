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

  factory AssetsModel.fromJson(Map<String, dynamic> json) => AssetsModel(
      id: json["id"],
      email: json["email"] ?? 'defaultemail@company.com',
      name: json["name"] ?? 'Unnamed Asset',
      assetId: json["assetId"]?.toString() ?? '000', // Convert to String
      serialNumber: json["serialNumber"] ?? 'Unknown Serial',
      customer: json["customer"] ?? 'Unknown Customer',
      customerId: json["customerId"] ?? 'Unknown Customer ID',
      location: json["location"] ?? '',
      status: json["status"] ?? '',
      category: json["category"] ?? '',
      image: json["image"],
      companyId: json["companyId"].toString());

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
