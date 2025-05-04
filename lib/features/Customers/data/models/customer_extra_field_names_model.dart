// To parse this JSON data, do
//
//     final CustomerExtraFieldNamesModel = CustomerExtraFieldNamesModelFromJson(jsonString);

import 'dart:convert';


CustomerExtraFieldNamesModel CustomerExtraFieldNamesModelFromJson(String str) => CustomerExtraFieldNamesModel.fromJson(json.decode(str));

String CustomerExtraFieldNamesModelToJson(CustomerExtraFieldNamesModel data) => json.encode(data.toJson());

class CustomerExtraFieldNamesModel {
    final String? id;
    final String name;
    final String type;
    final String companyId;
    

    CustomerExtraFieldNamesModel({
        this.id,
        required this.name,
        required this.type,
        required this.companyId,
    });

    factory CustomerExtraFieldNamesModel.fromJson(Map<String, dynamic> json) => CustomerExtraFieldNamesModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        companyId: json["companyId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "companyId": companyId,
    };
}


