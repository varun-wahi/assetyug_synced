// To parse this JSON data, do
//
//     final assetFilesModel = assetFilesModelFromJson(jsonString);

import 'dart:convert';


AssetFilesModel assetFilesModelFromJson(String str) => AssetFilesModel.fromJson(json.decode(str));


class AssetFilesModel {
    final String id;
    final String assetId;
    final String fileName;
    final String assetFile;

    AssetFilesModel({
        required this.id,
        required this.assetId,
        required this.fileName,
        required this.assetFile,
    });

    factory AssetFilesModel.fromJson(Map<String, dynamic> json) {
        return AssetFilesModel(
            id: json['id']?.toString() ?? '',
            assetId: json['assetId']?.toString() ?? '',
            fileName: json['fileName'] as String? ?? '',
            assetFile: json['file'] as String? ?? '',
        );
    }
}

