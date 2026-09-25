import 'package:clubship/colors.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets.dart';
import 'package:clubship/event_ticket/event_tickets_page.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:flutter/material.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Brutal.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Brutal.bg,
            padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY TICKETS',
                  style: Brutal.label(size: 11, color: Brutal.mute),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Passes',
                  style: Brutal.display(size: 30, color: Brutal.paper),
                ),
              ],
            ),
          ),

          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(2, (index) {
                final isSelected = _controller.index == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _controller.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: index == 0 ? 8 : 0, left: index == 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Brutal.magenta.withValues(alpha: 0.15)
                            : Brutal.card.withValues(alpha: 0.4),
                        border: Border.all(
                          color: isSelected
                              ? Brutal.magenta.withValues(alpha: 0.6)
                              : Brutal.hairlineColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            index == 0 ? Icons.confirmation_number : Icons.local_bar,
                            size: 16,
                            color: isSelected ? Brutal.magenta : Brutal.dim,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            index == 0 ? 'Event Tickets' : 'Drink Tickets',
                            style: Brutal.body(
                              size: 13,
                              color: isSelected ? Brutal.paper : Brutal.dim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                EventTicketsPage(),
                PurchasedDrinkTickets(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
