import 'package:intl/intl.dart';

class AssetCheckingDetailsModel {
  final String? status;
  final DateTime? date;
  final String? employee;
  final String? notes;
  final String? location;
  final String? userLocation;
  final String? userLatitude;
  final String? userLongitude;
  final String? ipAddress;
  final DateTime? updateTime;

  AssetCheckingDetailsModel({
    this.status,
    this.date,
    this.employee,
    this.notes,
    this.location,
    this.userLocation,
    this.userLatitude,
    this.userLongitude,
    this.ipAddress,
    this.updateTime,
  });

  factory AssetCheckingDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssetCheckingDetailsModel(
      status: json['status']?.toString(),
      date: _parseDate(json['date']),
      employee: json['employee']?.toString(),
      notes: json['notes']?.toString(),
      location: json['location']?.toString(),
      userLocation: json['userLocation']?.toString(),
      userLatitude: json['userLatitude']?.toString(),
      userLongitude: json['userLongitude']?.toString(),
      ipAddress: json['ipAddress']?.toString(),
      updateTime: _parseDate(json['updateTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "date": date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
        "employee": employee,
        "notes": notes,
        "location": location,
        "userLocation": userLocation,
        "userLatitude": userLatitude,
        "userLongitude": userLongitude,
        "ipAddress": ipAddress,
        "updateTime": updateTime?.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    if (dateData is List && dateData.length >= 3) {
      return DateTime(
        dateData[0] as int,
        dateData[1] as int,
        dateData[2] as int,
      );
    } else if (dateData is String) {
      return DateTime.tryParse(dateData);
    }
    return null;
  }
}
