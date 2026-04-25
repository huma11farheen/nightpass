import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/my_page/order_history/order_history_view_model.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:clubship/widgets/async_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/get_order_history_provider.dart';
import 'order_history_list_tile.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Order History',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorPallete.brightPink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: ColorPallete.brightPink,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No purchases yet',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order history will appear here',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedOrders.length,
              itemBuilder: (context, index) {
                final monthYear = groupedOrders.keys.elementAt(index);
                final ordersForMonth = groupedOrders[monthYear] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(left: 4, bottom: 16, top: index == 0 ? 0 : 24),
                      child: Row(
                        children: [
                          Container(

                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorPallete.brightPink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${monthYear.toMonthName(context, monthYear.substring(0, 2))} ${monthYear.substring(3)}',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...ordersForMonth.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OrderHistoryListTile(
                          orderHistoryViewModel: order,
                        ),
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
