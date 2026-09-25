import 'package:clubship/design/brutal.dart';
import 'package:clubship/my_page/order_history/order_history_view_model.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';

class OrderHistoryListTile extends StatelessWidget {
  const OrderHistoryListTile({super.key, required this.orderHistoryViewModel});

  final OrderHistoryViewModel orderHistoryViewModel;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _showOrderDetails(context),
        child: Container(
          decoration: BoxDecoration(
            color: Brutal.elevated,
            border: Border.all(color: Brutal.hairlineColor),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event image — square, no border radius
              SizedBox(
                height: 72,
                width: 72,
                child: NomuCachedNetworkImage(
                  imageUrl: orderHistoryViewModel.event.image,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderHistoryViewModel.event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Brutal.body(size: 17, color: Brutal.paper),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Brutal.magenta),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            orderHistoryViewModel.club.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Brutal.label(size: 10, color: Brutal.dim),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderHistoryViewModel.eventTicket.createdAt
                          .toDateString(pattern: 'MMM dd, yyyy • h:mm a'),
                      style: Brutal.label(size: 10, color: Brutal.mute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Price + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¥${orderHistoryViewModel.eventTicket.price.toInt()}',
                    style: Brutal.label(size: 15, color: Brutal.magenta),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Brutal.mute),
                ],
              ),
            ],
          ),
        ),
      );

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Brutal.elevated,
          border: Border(top: BorderSide(color: Brutal.hairlineColor)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 32, height: 3, color: Brutal.mute),
            ),
            const SizedBox(height: 20),

            Text('Order Details', style: Brutal.display(size: 24, color: Brutal.paper)),
            const SizedBox(height: 20),

            // Event image
            SizedBox(
              height: 160,
              width: double.infinity,
              child: NomuCachedNetworkImage(
                imageUrl: orderHistoryViewModel.event.image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            _DetailRow(icon: Icons.event_outlined, label: 'EVENT', value: orderHistoryViewModel.event.name),
            Container(height: 1, color: Brutal.hairlineColor),
            _DetailRow(icon: Icons.location_city_outlined, label: 'VENUE', value: orderHistoryViewModel.club.name),
            Container(height: 1, color: Brutal.hairlineColor),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'EVENT DATE',
              value: orderHistoryViewModel.event.startDate
                  .toDateString(pattern: 'EEEE, MMMM dd, yyyy'),
            ),
            Container(height: 1, color: Brutal.hairlineColor),
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'PURCHASED ON',
              value: orderHistoryViewModel.eventTicket.createdAt
                  .toDateString(pattern: 'MMM dd, yyyy • h:mm a'),
            ),
            Container(height: 1, color: Brutal.hairlineColor),
            _DetailRow(icon: Icons.confirmation_number_outlined, label: 'TICKET TYPE', value: 'Standard'),

            const SizedBox(height: 20),

            // Total amount block
            Container(
              decoration: BoxDecoration(
                color: Brutal.bg,
                border: Border.all(color: Brutal.magenta, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL AMOUNT', style: Brutal.label(size: 11, color: Brutal.dim)),
                  Text(
                    '¥${orderHistoryViewModel.eventTicket.price.toInt()}',
                    style: Brutal.label(size: 19, color: Brutal.magenta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Brutal.mute),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Brutal.label(size: 10, color: Brutal.mute)),
                const SizedBox(height: 3),
                Text(value, style: Brutal.body(size: 16, color: Brutal.paper)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
