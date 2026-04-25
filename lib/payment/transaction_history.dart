import 'package:clubship/payment/get_user_wallet_events.dart';
import 'package:clubship/payment/transaction_list_tile.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:clubship/data/supabase_models/user_wallet_event.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userWalletEventAsyncValue = ref.watch(getUserWalletEventsProvider);

    return Scaffold(
      body: userWalletEventAsyncValue.when(
        data: (data) {
          if (data.isEmpty) {
            return const Text('Empty');
          }

          final eventsByDay = groupBy(
            data,
                (o) => o.createdAt
                .toDateString(pattern: DateTimeFormat.yMMddSlash)
                .replaceAll('/', ''),
          );

          final sortedDays = eventsByDay.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          eventsByDay.forEach((day, orders) {
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          });

          return ListView.builder(
            itemCount: sortedDays.length,
            itemBuilder: (context, index) {
              final day = sortedDays[index];
              final eventsForDay = eventsByDay[day];

              final dateString =
                  '${day.substring(0, 4)}/${day.substring(4, 6)}/${day.substring(6, 8)}';
              final date = DateTime.parse(dateString.replaceAll('/', '-'));
              final isToday =
                  date.difference(DateTime.now().toLocal()).inDays == 0;
              final isYesterday =
                  date.difference(DateTime.now().toLocal()).inDays == -1;

              String dateHeader;

              if (isToday) {
                dateHeader = 'Today';
              } else if (isYesterday) {
                dateHeader = 'Yesterday';
              } else {
                dateHeader = DateFormat(DateTimeFormat.mmmmD).format(date);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateHeader,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: eventsForDay
                        ?.map(
                          (event) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransactionListTile(
                            userWalletEvent: event,
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                        .toList() ??
                        [],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        error: (err, st) =>
            const Text('Error getting transaction history'),
        loading: () {
          // Create mock data for skeleton preview
          final mockEvents = List.generate(
            8,
            (index) => UserWalletEvent(
              id: 'mock-$index',
              createdAt: DateTime.now()
                  .subtract(Duration(days: index ~/ 3))
                  .toIso8601String(),
              reason: index % 2 == 0 ? 'Deposit' : 'Booking Payment',
              balanceChange: index % 2 == 0 ? 5000 : -2500,
            ),
          );

          final eventsByDay = groupBy(
            mockEvents,
            (o) => o.createdAt
                .toDateString(pattern: DateTimeFormat.yMMddSlash)
                .replaceAll('/', ''),
          );

          final sortedDays = eventsByDay.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return Skeletonizer(
            child: ListView.builder(
              itemCount: sortedDays.length,
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                final eventsForDay = eventsByDay[day];

                final dateString =
                    '${day.substring(0, 4)}/${day.substring(4, 6)}/${day.substring(6, 8)}';
                final date = DateTime.parse(dateString.replaceAll('/', '-'));
                final isToday =
                    date.difference(DateTime.now().toLocal()).inDays == 0;
                final isYesterday =
                    date.difference(DateTime.now().toLocal()).inDays == -1;

                String dateHeader;

                if (isToday) {
                  dateHeader = 'Today';
                } else if (isYesterday) {
                  dateHeader = 'Yesterday';
                } else {
                  dateHeader = DateFormat(DateTimeFormat.mmmmD).format(date);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateHeader,
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: eventsForDay
                              ?.map(
                                (event) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TransactionListTile(
                                      userWalletEvent: event,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
