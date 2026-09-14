class TrialStatusDetails {
  final String? id;
  final String? customerEmail;
  final int? companyId;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final bool trialExpired;
  final bool trialExpirationNotificationSent;
  final bool finalWarningNotificationSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? lastUpdatedBy;
  final bool trialActive;

  const TrialStatusDetails({
    this.id,
    this.customerEmail,
    this.companyId,
    this.trialStartDate,
    this.trialEndDate,
    this.trialExpired = false,
    this.trialExpirationNotificationSent = false,
    this.finalWarningNotificationSent = false,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.lastUpdatedBy,
    this.trialActive = false,
  });

  factory TrialStatusDetails.fromJson(Map<String, dynamic> json) {
    return TrialStatusDetails(
      id: json['id']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      companyId: json['companyId'] is int
          ? json['companyId'] as int
          : int.tryParse(json['companyId']?.toString() ?? ''),
      trialStartDate: DateTime.tryParse(json['trialStartDate']?.toString() ?? ''),
      trialEndDate: DateTime.tryParse(json['trialEndDate']?.toString() ?? ''),
      trialExpired: json['trialExpired'] == true,
      trialExpirationNotificationSent:
          json['trialExpirationNotificationSent'] == true,
      finalWarningNotificationSent:
          json['finalWarningNotificationSent'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      createdBy: json['createdBy']?.toString(),
      lastUpdatedBy: json['lastUpdatedBy']?.toString(),
      trialActive: json['trialActive'] == true,
    );
  }

  /// Whole calendar days from today until [trialEndDate].
  /// 1 = expires tomorrow, 0 = expires today, negative = already ended.
  int get daysRemaining {
    final end = trialEndDate;
    if (end == null) return 0;
    final now = DateTime.now();
    final endDay = DateTime(end.year, end.month, end.day);
    final today = DateTime(now.year, now.month, now.day);
    return endDay.difference(today).inDays;
  }

  bool get hasEnded => daysRemaining < 0;
}
