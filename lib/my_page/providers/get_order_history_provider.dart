import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/my_page/order_history/order_history_view_model.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_order_history_provider.g.dart';

@riverpod
class OrderHistory extends _$OrderHistory {
  @override
  Future<List<OrderHistoryViewModel>> build() async =>
      ref.watch(eventRepositoryProvider).fetchOrderHistory();
}

@riverpod
Future<Map<String, List<OrderHistoryViewModel>>> processedOrderHistory(
    Ref ref) async {
  final orders = await ref.watch(orderHistoryProvider.future);

  if (orders.isEmpty) {
    return {};
  }


  final ordersByMonthYear = groupBy(
      orders, (o) => o.eventTicket.createdAt.toDateString(pattern: 'MM y'));

  final sortedMonths = ordersByMonthYear.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  final result = <String, List<OrderHistoryViewModel>>{};
  for (var month in sortedMonths) {
    final ordersForMonth = ordersByMonthYear[month] ?? [];
    ordersForMonth.sort((a, b) => b.eventTicket.createdAt.compareTo(a.eventTicket.createdAt));
    result[month] = ordersForMonth;
  }

  return result;
}
