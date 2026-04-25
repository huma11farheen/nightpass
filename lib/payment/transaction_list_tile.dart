import 'package:clubship/data/supabase_models/user_wallet_event.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.userWalletEvent,
  });

  final UserWalletEvent userWalletEvent;

  String _setEventTitle(BuildContext context) {
    switch (userWalletEvent.reason) {
      case 'drink_order':
        return '';
      case 'top_up':
        return '';
      case 'refund_taso_rental':
        return '';
      case 'refund_expired_order':
        return '';
      default:
        return '';
    }
  }

  Widget _setEventThumbnail(BuildContext context) {
    switch (userWalletEvent.reason) {
      case 'drink_order':
        return AppIcons.money();
      default:
        return AppIcons.money();
    }
  }

  String _setBalanceChangeText(BuildContext context) {
    switch (userWalletEvent.reason) {
      case 'drink_order':
        return formatCurrency(userWalletEvent.balanceChange.abs().toDouble());
      default:
        return '+${formatCurrency(userWalletEvent.balanceChange.toDouble())}';
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => (userWalletEvent.reason != 'top_up')
        ? context.push(Routes.transactionDetail(userWalletEvent.id))
        : null,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Column(
            children: [
              const SizedBox(height: 4),
              SizedBox(
                width: 50,
                height: 50,
                child: _setEventThumbnail(context),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _setEventTitle(context),
                  ),
                  Text(
                    userWalletEvent.createdAt
                        .toDateString(pattern: DateTimeFormat.yMMddhmSlash),
                  ),
                ],
              ),
            ),
          ),
          Text(
            _setBalanceChangeText(context),
          ),
          if (userWalletEvent.reason != 'top_up') ...[
            const SizedBox(width: 24),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 26,
            )
          ]
        ],
      ),
    ),
  );
}
