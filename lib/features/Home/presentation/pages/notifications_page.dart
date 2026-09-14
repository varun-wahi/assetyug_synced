import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_gap.dart';
import 'package:asset_yug_debugging/features/Home/data/models/notification_model.dart';
import 'package:asset_yug_debugging/features/Home/presentation/riverpod/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(notificationsProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.notifications_off_outlined, size: 48, color: tTextMuted),
          const DGap(),
          Center(
            child: Text(
              'Could not load notifications',
              style: subheading(color: tTextMuted),
            ),
          ),
          const DGap(),
          Center(
            child: TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.notifications_none, size: 48, color: tTextMuted),
          const DGap(),
          Center(
            child: Text(
              'No notifications yet',
              style: subheading(color: tTextMuted),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(dPadding),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const DGap(),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _NotificationTile(
          notification: state.items[index],
          onTap: () => _showNotificationDetails(state.items[index]),
        );
      },
    );
  }

  void _showNotificationDetails(UserNotification notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.title, style: headline(size: 16)),
              const DGap(),
              if (notification.message.isNotEmpty)
                Text(notification.message, style: body(size: 14)),
              const DGap(gap: 16),
              Text(
                _formatTimestamp(notification.deliveredAt ??
                    notification.notification.createdAt),
                style: body(color: tTextMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    return ListTile(
      tileColor: isUnread ? tActiveAssetsCardBg : tBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dBorderRadius),
      ),
      onTap: onTap,
      leading: Icon(
        _iconForAlert(notification.notification.alertType),
        color: isUnread ? tPrimary : tTextMuted,
      ),
      title: Text(
        notification.title,
        style: containerText(
          weight: isUnread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.message.isNotEmpty)
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: body(color: tTextMuted),
            ),
          Text(
            _formatTimestamp(
              notification.deliveredAt ?? notification.notification.createdAt,
            ),
            style: body(size: 11, color: tTextMuted),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: tPrimary),
    );
  }

  IconData _iconForAlert(String? alertType) {
    switch (alertType) {
      case 'TRIAL_WARNING':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }
}

String _formatTimestamp(DateTime? dateTime) {
  if (dateTime == null) return '';
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(local);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return DateFormat('MMM d, yyyy').format(local);
}
