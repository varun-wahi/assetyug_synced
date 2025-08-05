// Create new file: lib/features/Assets/data/models/asset_filter_model.dart
class AssetFilterModel {
  final String? assetId;
  final String? name;
  final String? customer;
  final String? serialNumber;
  final String? category;
  final String? location;
  final String? status;

  AssetFilterModel({
    this.assetId,
    this.name,
    this.customer,
    this.serialNumber,
    this.category,
    this.location,
    this.status,
  });

  factory AssetFilterModel.fromMap(Map<String, dynamic> map) {
    return AssetFilterModel(
      assetId: map['assetId']?.toString(),
      name: map['name']?.toString(),
      customer: map['customer']?.toString(),
      serialNumber: map['serialNumber']?.toString(),
      category: map['category']?.toString(),
      location: map['location']?.toString(),
      status: map['status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assetId': assetId ?? '',
      'name': name ?? '',
      'customer': customer ?? '',
      'serialNumber': serialNumber ?? '',
      'category': category ?? '',
      'location': location ?? '',
      'status': status ?? '',
    };
  }

  AssetFilterModel copyWith({
    String? assetId,
    String? name,
    String? customer,
    String? serialNumber,
    String? category,
    String? location,
    String? status,
  }) {
    return AssetFilterModel(
      assetId: assetId ?? this.assetId,
      name: name ?? this.name,
      customer: customer ?? this.customer,
      serialNumber: serialNumber ?? this.serialNumber,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
}