class AssetBySerialDTO {

    String companyId;
    String serialNumber;

    AssetBySerialDTO({required this.companyId, required this.serialNumber});

    // Convert a JSON map to an AssetBySerialDTO instance
    factory AssetBySerialDTO.fromJson(Map<String, dynamic> json) {
        return AssetBySerialDTO(
            companyId: json['companyId'],
            serialNumber: json['serialNumber'],
        );
    }

    // Convert an AssetBySerialDTO instance to a JSON map
    Map<String, dynamic> toJson() {
        return {
            'companyId': companyId,
            'serialNumber': serialNumber,
        };
    }
}