import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/data/supabase_models/in_app_notification.dart';
import 'package:clubship/notifications/providers/get_notifications_provider.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/async_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Brutal.bg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            color: Brutal.bg,
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 16),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 14),
                Text('Notifications',
                    style: Brutal.display(size: 22, color: Brutal.paper)),
              ],
            ),
          ),
          Container(height: 1, color: Brutal.hairlineColor),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: AsyncValueWidget<List<InAppNotification>>(
              value: ref.watch(getNotificationsProvider),
              error: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      color: Brutal.elevated,
                      child: const Icon(Icons.error_outline,
                          color: Brutal.mute, size: 32),
                    ),
                    const SizedBox(height: 20),
                    Text('Failed to load',
                        style: Brutal.display(size: 20, color: Brutal.paper)),
                  ],
                ),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          color: Brutal.elevated,
                          child: const Icon(Icons.notifications_none,
                              color: Brutal.mute, size: 32),
                        ),
                        const SizedBox(height: 20),
                        Text('No notifications',
                            style: Brutal.display(size: 20, color: Brutal.paper)),
                        const SizedBox(height: 6),
                        Text("We'll notify you when something arrives",
                            style: Brutal.body(size: 14, color: Brutal.mute)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Brutal.magenta,
                  backgroundColor: Brutal.card,
                  onRefresh: () async {
                    ref.invalidate(getNotificationsProvider);
                    await Future.delayed(const Duration(milliseconds: 1200));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        Container(height: 1, color: Brutal.hairlineColor),
                    itemBuilder: (context, i) =>
                        _NotificationRow(notification: notifications[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});
  final InAppNotification notification;

  IconData _icon() {
    final t = notification.title?.toLowerCase() ?? '';
    if (t.contains('ticket')) return Icons.confirmation_number_outlined;
    if (t.contains('event')) return Icons.event_outlined;
    if (t.contains('payment') || t.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('promo') || t.contains('offer')) return Icons.local_offer_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Brutal.elevated,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 36,
            height: 36,
            color: Brutal.card,
            child: Icon(_icon(), color: Brutal.magenta, size: 18),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? 'Notification',
                  style: Brutal.body(size: 16, color: Brutal.paper),
                ),
                if (notification.content != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.content!,
                    style: Brutal.body(size: 14, color: Brutal.dim),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  notification.createdAt
                      .toDateString(pattern: 'MMM dd · h:mm a'),
                  style: Brutal.label(size: 9, color: Brutal.mute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
