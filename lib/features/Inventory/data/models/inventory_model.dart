class InventoryModel {
  final String partId;
  final String partName;
  final double price;
  final double cost;
  final String category;
  final int quantity;
  final String? imageBase64; // Optional, nullable

  InventoryModel({
    required this.partId,
    required this.partName,
    required this.price,
    required this.cost,
    required this.category,
    required this.quantity,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
        "part_id": partId,
        "part_name": partName,
        "price": price,
        "cost": cost,
        "category": category,
        "quantity": quantity,
        if (imageBase64 != null) "image": imageBase64,
      };

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      partId: json["part_id"] ?? '',
      partName: json["part_name"] ?? '',
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
      cost: (json["cost"] as num?)?.toDouble() ?? 0.0,
      category: json["category"] ?? '',
      quantity: json["quantity"] ?? 0,
      imageBase64: json["image"],
    );
  }
}
