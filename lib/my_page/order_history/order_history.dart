import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/my_page/order_history/order_history_view_model.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/async_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/get_order_history_provider.dart';
import 'order_history_list_tile.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: Brutal.bg,
        appBar: AppBar(
          backgroundColor: Brutal.bg,
          elevation: 0,
          leading: const AppBackButton(forAppBar: true),
          title: Text('My Bookings', style: Brutal.display(size: 20, color: Brutal.paper)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Brutal.hairlineColor),
          ),
        ),
        body: AsyncValueWidget<Map<String, List<OrderHistoryViewModel>>>(
          value: ref.watch(processedOrderHistoryProvider),
          data: (groupedOrders) {
            if (groupedOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      color: Brutal.elevated,
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 36,
                        color: Brutal.mute,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No purchases yet',
                      style: Brutal.display(size: 22, color: Brutal.paper),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order history will appear here',
                      style: Brutal.body(size: 15, color: Brutal.mute),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: groupedOrders.length,
              itemBuilder: (context, index) {
                final monthYear = groupedOrders.keys.elementAt(index);
                final ordersForMonth = groupedOrders[monthYear] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 28),
                      child: Row(
                        children: [
                          Container(width: 2, height: 12, color: Brutal.magenta),
                          const SizedBox(width: 10),
                          Text(
                            '${monthYear.toMonthName(context, monthYear.substring(0, 2))} ${monthYear.substring(3)}'.toUpperCase(),
                            style: Brutal.label(size: 11, color: Brutal.dim),
                          ),
                        ],
                      ),
                    ),
                    ...ordersForMonth.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: OrderHistoryListTile(orderHistoryViewModel: order),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
}
