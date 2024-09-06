import 'assets_checking_details_model.dart';

class AssetCheckInOutModel {
  final String? id;
  final String? assetId;
  final String? status;
  final List<AssetCheckingDetailsModel> detailsList;

  AssetCheckInOutModel({
    this.id,
    this.assetId,
    this.status,
    required this.detailsList,
  });

  factory AssetCheckInOutModel.fromJson(Map<String, dynamic> json) {
    return AssetCheckInOutModel(
      id: json['id']?.toString(),
      assetId: json['assetId']?.toString(),
      status: json['status'],
      detailsList: (json['detailsList'] as List<dynamic>?)
          ?.map((detail) => AssetCheckingDetailsModel.fromJson(detail))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "assetId": assetId,
        "detailsList": List<dynamic>.from(detailsList.map((x) => x.toJson())),
        "status": status,
      };
}

