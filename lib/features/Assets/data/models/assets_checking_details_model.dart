import 'package:intl/intl.dart';

class AssetCheckingDetailsModel {
  final String? status;
  final DateTime? date;
  final String? employee;
  final String? notes;
  final String? location;

  AssetCheckingDetailsModel({
    this.status,
    this.date,
    this.employee,
    this.notes,
    this.location,
  });

  factory AssetCheckingDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssetCheckingDetailsModel(
      status: json['status'] as String?,
      date: _parseDate(json['date']),
      employee: json['employee'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "date": date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
        "employee": employee,
        "notes": notes,
        "location": location,
      };

  static DateTime? _parseDate(dynamic dateData) {
    if (dateData == null) return null;
    if (dateData is List && dateData.length == 3) {
      return DateTime(dateData[0], dateData[1], dateData[2]);
    } else if (dateData is String) {
      return DateTime.tryParse(dateData);
    }
    return null;
  }
}