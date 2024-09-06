// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/mongo_dart.dart';

CustomersModel mongoDbModelFromJson(String str) =>
    CustomersModel.fromJson(json.decode(str));

String mongoDbModelToJson(CustomersModel data) => json.encode(data.toJson());

class CustomersModel {
    ObjectId id;
    int companyCustomerId;
    String name;
    String companyId;
    String category;
    String status;
    Int64 phone;
    String email;
    String address;
    String apartment;
    String city;
    String state;
    int zipCode;

    CustomersModel({
        required this.id,
        required this.companyCustomerId,
        required this.name,
        required this.companyId,
        required this.category,
        required this.status,
        required this.phone,
        required this.email,
        required this.address,
        required this.apartment,
        required this.city,
        required this.state,
        required this.zipCode,
    });

    factory CustomersModel.fromJson(Map<String, dynamic> json) => CustomersModel(
        id: json["_id"],
        companyCustomerId: json["companyCustomerId"],
        name: json["name"],
        companyId: json["companyId"],
        category: json["category"],
        status: json["status"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        apartment: json["apartment"],
        city: json["city"],
        state: json["state"],
        zipCode: json["zipCode"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "companyCustomerId": companyCustomerId,
        "name": name,
        "companyId": companyId,
        "category": category,
        "status": status,
        "phone": phone,
        "email": email,
        "address": address,
        "apartment": apartment,
        "city": city,
        "state": state,
        "zipCode": zipCode,
    };
}


