// To parse this JSON data, do
//
//     final mongoDbWorkOrdersModel = mongoDbWorkOrdersModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

WorkOrdersModel mongoDbWorkOrdersModelFromJson(String str) => WorkOrdersModel.fromJson(json.decode(str));

String mongoDbWorkOrdersModelToJson(WorkOrdersModel data) => json.encode(data.toJson());

class WorkOrdersModel {
    ObjectId id;
    String description;
    String customerName;
    String status;
    String priority;
    DateTime dueDate;
    String assignedTechnician;
    String assetDetails;
    DateTime lastDate;
    int assetId;
    String customerId;

    WorkOrdersModel({
        required this.id,
        required this.description,
        required this.customerName,
        required this.status,
        required this.priority,
        required this.dueDate,
        required this.assignedTechnician,
        required this.assetDetails,
        required this.lastDate,
        required this.assetId,
        required this.customerId,
    });

    factory WorkOrdersModel.fromJson(Map<String, dynamic> json) => WorkOrdersModel(
        id: json["_id"],
        description: json["description"],
        customerName: json["customerName"],
        status: json["status"],
        priority: json["priority"],
        dueDate: json["dueDate"],
        assignedTechnician: json["assignedTechnician"],
        assetDetails: json["assetDetails"],
        lastDate: json["lastDate"],
        assetId: json["assetId"],
        customerId: json["customerId"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "description": description,
        "customerName": customerName,
        "status": status,
        "priority": priority,
        "dueDate": dueDate,
        "assignedTechnician": assignedTechnician,
        "assetDetails": assetDetails,
        "lastDate": lastDate,
        "customerId": customerId,
        "assetId": assetId
    };
}
