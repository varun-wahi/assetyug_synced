class NotificationPayload {
  final String? id;
  final String? title;
  final String? message;
  final String? notificationType;
  final String? alertType;
  final int? companyId;
  final DateTime? createdAt;
  final DateTime? expiryAt;
  final String? createdBy;
  final String? lastUpdatedBy;

  const NotificationPayload({
    this.id,
    this.title,
    this.message,
    this.notificationType,
    this.alertType,
    this.companyId,
    this.createdAt,
    this.expiryAt,
    this.createdBy,
    this.lastUpdatedBy,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationPayload();
    return NotificationPayload(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      notificationType: json['notificationType']?.toString(),
      alertType: json['alertType']?.toString(),
      companyId: json['companyId'] is int
          ? json['companyId'] as int
          : int.tryParse(json['companyId']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      expiryAt: DateTime.tryParse(json['expiryAt']?.toString() ?? ''),
      createdBy: json['createdBy']?.toString(),
      lastUpdatedBy: json['lastUpdatedBy']?.toString(),
    );
  }
}

class UserNotification {
  final String? id;
  final String? userId;
  final String? notificationId;
  final int? companyId;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final NotificationPayload notification;
  final String? createdBy;
  final String? lastUpdatedBy;
  final bool read;

  const UserNotification({
    this.id,
    this.userId,
    this.notificationId,
    this.companyId,
    this.readAt,
    this.deliveredAt,
    this.notification = const NotificationPayload(),
    this.createdBy,
    this.lastUpdatedBy,
    this.read = false,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      notificationId: json['notificationId']?.toString(),
      companyId: json['companyId'] is int
          ? json['companyId'] as int
          : int.tryParse(json['companyId']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      notification: json['notification'] is Map<String, dynamic>
          ? NotificationPayload.fromJson(
              json['notification'] as Map<String, dynamic>,
            )
          : const NotificationPayload(),
      createdBy: json['createdBy']?.toString(),
      lastUpdatedBy: json['lastUpdatedBy']?.toString(),
      read: json['read'] == true,
    );
  }

  String get title => notification.title ?? 'Notification';
  String get message => notification.message ?? '';
}

class PaginatedNotifications {
  final List<UserNotification> notifications;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasMore;

  const PaginatedNotifications({
    this.notifications = const [],
    this.pageNumber = 0,
    this.pageSize = 10,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasMore = false,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    final rawList = json['notifications'];
    return PaginatedNotifications(
      notifications: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(UserNotification.fromJson)
              .toList()
          : const [],
      pageNumber: json['pageNumber'] is int
          ? json['pageNumber'] as int
          : int.tryParse(json['pageNumber']?.toString() ?? '') ?? 0,
      pageSize: json['pageSize'] is int
          ? json['pageSize'] as int
          : int.tryParse(json['pageSize']?.toString() ?? '') ?? 10,
      totalCount: json['totalCount'] is int
          ? json['totalCount'] as int
          : int.tryParse(json['totalCount']?.toString() ?? '') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse(json['totalPages']?.toString() ?? '') ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }

  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;
}
