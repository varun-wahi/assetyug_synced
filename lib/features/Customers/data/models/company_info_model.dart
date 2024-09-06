// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

CompanyInfoModel mongoDbModelFromJson(String str) =>
    CompanyInfoModel.fromJson(json.decode(str));

String mongoDbModelToJson(CompanyInfoModel data) => json.encode(data.toJson());

class CompanyInfoModel {
  String id;
  String companyID;
  String companyName;
  String companyEmail;
  String? companyImage;  // Make this nullable

  CompanyInfoModel({
    required this.id,
    required this.companyID,
    required this.companyEmail,
    required this.companyName,
    this.companyImage,  // Remove default value
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) => CompanyInfoModel(
        id: json["id"] ?? '',  // Provide default values
        companyID: json["companyID"] ?? '',
        companyEmail: json["companyEmail"] ?? '',
        companyName: json["companyName"] ?? '',
        companyImage: json["companyImage"],  // This can be null
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyID": companyID,
        "companyEmail": companyEmail,
        "companyName": companyName,
        "companyImage": companyImage,
      };
}
