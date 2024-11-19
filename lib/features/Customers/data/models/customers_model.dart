class CustomersModel {
  String? id;
  String? companyCustomerId;
  String? name;
  String? companyId;
  String? category;
  String? status;
  String? phone;
  String? email;
  String? address;
  String? apartment;
  String? city;
  String? state;
  String? zipCode;

  CustomersModel({
    this.id,
    this.companyCustomerId,
    this.name,
    this.companyId,
    this.category,
    this.status,
    this.phone,
    this.email,
    this.address,
    this.apartment,
    this.city,
    this.state,
    this.zipCode,
  });

  factory CustomersModel.fromJson(Map<String, dynamic> json) => CustomersModel(
        id: json["id"],
        companyCustomerId: json["companyCustomerId"].toString(),
        name: json["name"],
        companyId: json["companyId"],
        category: json["category"],
        status: json["status"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        apartment: json["apartment"],
        city: json["city"],
        state: json["state"],
        // Handle both int and String zipCode by converting it to String
        zipCode: json["zipCode"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyCustomerId": companyCustomerId,
        "name": name,
        "companyId": companyId,
        "category": category,
        "status": status,
        "phone": phone,
        "email": email,
        "address": address,
        "apartment": apartment,
        "city": city,
        "state": state,
        "zipCode": zipCode,
      };
}