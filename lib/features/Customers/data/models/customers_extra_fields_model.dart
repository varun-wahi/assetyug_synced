import 'dart:convert';


CustomerExtraFieldModel CustomerExtraFieldModelFromJson(String str) => CustomerExtraFieldModel.fromJson(json.decode(str));

String CustomerExtraFieldModelToJson(CustomerExtraFieldModel data) => json.encode(data.toJson());

class CustomerExtraFieldModel {
    String? companyId;
    String? email;
    String? id;
    String name;
    String value;
    String? customerId;
    String type;

    CustomerExtraFieldModel({
        this.companyId,
        this.email,
        this.id,
        required this.name,
        required this.value,
        this.customerId,
        required this.type,
    });

    factory CustomerExtraFieldModel.fromJson(Map<String, dynamic> json) {
        return CustomerExtraFieldModel(
            companyId: json['companyId'] as String?,
            email: json['email'] as String?,
            id: json['id'] as String?,
            name: json['name'] as String? ?? '',
            value: json['value'] as String? ?? '',
            customerId: json['assetId'] as String?,
            type: json['type'] as String? ?? '',
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "value": value,
        "customerId": customerId,
        "companyId": companyId,
        "type": type,
    };
}


