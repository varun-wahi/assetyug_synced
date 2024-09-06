// To parse this JSON data, do
//
//     final AssetExtraFieldNamesModel = AssetExtraFieldNamesModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

AssetExtraFieldNamesModel AssetExtraFieldNamesModelFromJson(String str) => AssetExtraFieldNamesModel.fromJson(json.decode(str));

String AssetExtraFieldNamesModelToJson(AssetExtraFieldNamesModel data) => json.encode(data.toJson());

class AssetExtraFieldNamesModel {
    final String? id;
    final String name;
    final String type;
    final String companyId;
    

    AssetExtraFieldNamesModel({
        this.id,
        required this.name,
        required this.type,
        required this.companyId,
    });

    factory AssetExtraFieldNamesModel.fromJson(Map<String, dynamic> json) => AssetExtraFieldNamesModel(
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


