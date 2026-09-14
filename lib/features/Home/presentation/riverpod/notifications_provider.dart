import 'package:asset_yug_debugging/features/Home/data/models/notification_model.dart';
import 'package:asset_yug_debugging/features/Home/data/repository/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepositoryImpl>((ref) => NotificationRepositoryImpl());

class NotificationsState {
  final List<UserNotification> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasMore;

  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pageNumber = 0,
    this.pageSize = 10,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasMore = false,
  });

  int get unreadCount => items.where((item) => !item.read).length;

  NotificationsState copyWith({
    List<UserNotification>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasMore,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._repository) : super(const NotificationsState());

  final NotificationRepositoryImpl _repository;
  static const int _pageSize = 10;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.getUserNotifications(
        pageNumber: 0,
        pageSize: _pageSize,
      );
      state = NotificationsState(
        items: page.notifications,
        isLoading: false,
        pageNumber: page.pageNumber,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.pageNumber + 1;
      final page = await _repository.getUserNotifications(
        pageNumber: nextPage,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...page.notifications],
        isLoadingMore: false,
        pageNumber: page.pageNumber,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(notificationRepositoryProvider));
});
