import 'dart:convert';


AssetExtraFieldModel AssetExtraFieldModelFromJson(String str) => AssetExtraFieldModel.fromJson(json.decode(str));

String AssetExtraFieldModelToJson(AssetExtraFieldModel data) => json.encode(data.toJson());

class AssetExtraFieldModel {
    String? companyId;
    String? email;
    String? id;
    String name;
    String value;
    String? assetId;
    String type;

    AssetExtraFieldModel({
        this.companyId,
        this.email,
        this.id,
        required this.name,
        required this.value,
        this.assetId,
        required this.type,
    });

    factory AssetExtraFieldModel.fromJson(Map<String, dynamic> json) {
        return AssetExtraFieldModel(
            companyId: json['companyId'] as String?,
            email: json['email'] as String?,
            id: json['id'] as String?,
            name: json['name'] as String? ?? '',
            value: json['value'] as String? ?? '',
            assetId: json['assetId'] as String?,
            type: json['type'] as String? ?? '',
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "value": value,
        "assetId": assetId,
        "companyId": companyId,
        "type": type,
    };
}


