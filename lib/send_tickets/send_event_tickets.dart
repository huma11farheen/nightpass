import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event_ticket/event_tickets_page.dart';
import 'package:clubship/send_tickets/provider/send_event_ticket_view_model.dart';
import 'package:clubship/send_tickets/user_tile.dart';
import 'package:clubship/widgets/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SendTickets extends ConsumerStatefulWidget {
  const SendTickets({super.key, required this.ticketId});
  final String ticketId;

  @override
  ConsumerState<SendTickets> createState() => _SendTicketsState();
}

class _SendTicketsState extends ConsumerState<SendTickets> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear previous search results every time this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendTicketViewModel.notifier).reset();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendTicketViewModel);
    final notifier = ref.read(sendTicketViewModel.notifier);
    final users = state.users;
    final selectedUser = state.selectedUser;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Brutal.bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            color: Brutal.bg,
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 14),
                    Text('Send Ticket',
                        style: Brutal.display(size: 22, color: Brutal.paper)),
                  ],
                ),
                const SizedBox(height: 20),

                // Search field — triggers on every keystroke
                Container(
                  decoration: BoxDecoration(
                    color: Brutal.elevated,
                    border: Border.all(color: Brutal.hairlineColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => notifier.getUsers(v),
                    style: Brutal.body(size: 16, color: Brutal.paper),
                    cursorColor: Brutal.magenta,
                    decoration: InputDecoration(
                      hintText: 'Search by username...',
                      hintStyle: Brutal.body(size: 16, color: Brutal.mute),
                      prefixIcon: const Icon(Icons.search,
                          color: Brutal.mute, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                notifier.reset();
                                setState(() {});
                              },
                              child: const Icon(Icons.close,
                                  color: Brutal.mute, size: 16),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                if (selectedUser != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Brutal.bg,
                      border: Border.all(color: Brutal.magenta, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline,
                            color: Brutal.magenta, size: 14),
                        const SizedBox(width: 8),
                        Text('SENDING TO  ',
                            style: Brutal.label(size: 10, color: Brutal.mute)),
                        Text(
                          selectedUser.username ?? 'User',
                          style: Brutal.label(size: 10, color: Brutal.magenta),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(height: 1, color: Brutal.hairlineColor),

          // ── User list ───────────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Brutal.magenta, strokeWidth: 2))
                : users.isEmpty
                    ? _searchController.text.isEmpty
                        ? const _IdleState()
                        : const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          final user = users[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: UserTile(
                              name: user.username ?? '',
                              image: user.image ?? '',
                              isSelected: user.id == selectedUser?.id,
                              onSelected: () => notifier.setSelectedUser(user),
                            ),
                          );
                        },
                      ),
          ),

          // ── Send button ─────────────────────────────────────────────────────
          Container(
            color: Brutal.bg,
            padding: EdgeInsets.fromLTRB(20, 12, 20, botPad + 16),
            child: GestureDetector(
              onTap: () async {
                if (selectedUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Select a user first'),
                    backgroundColor: Brutal.elevated,
                  ));
                  return;
                }
                final ok =
                    await notifier.sendTicket(ticketId: widget.ticketId);
                if (!context.mounted) return;
                if (ok) {
                  ref.read(eventTicketsProvider.notifier).refreshTickets();
                  await showCustomAlertDialog(
                    context: context,
                    title: 'Ticket Sent',
                    message:
                        'Ticket sent to ${selectedUser.username ?? "the user"}',
                    onConfirm: () => context.pop(),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Failed to send ticket. Try again.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Container(
                width: double.infinity,
                color: selectedUser != null ? Brutal.magenta : Brutal.elevated,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, color: Brutal.paper, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      selectedUser != null
                          ? 'SEND TO ${(selectedUser.username ?? '').toUpperCase()}'
                          : 'SEND TICKET',
                      style: Brutal.label(size: 12, color: Brutal.paper),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              color: Brutal.elevated,
              child: const Icon(Icons.search, color: Brutal.mute, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Search for a user',
                style: Brutal.display(size: 20, color: Brutal.paper)),
            const SizedBox(height: 6),
            Text('Type a username above',
                style: Brutal.body(size: 14, color: Brutal.mute)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              color: Brutal.elevated,
              child: const Icon(Icons.person_search_outlined,
                  color: Brutal.mute, size: 32),
            ),
            const SizedBox(height: 20),
            Text('No users found',
                style: Brutal.display(size: 20, color: Brutal.paper)),
            const SizedBox(height: 6),
            Text('Try a different username',
                style: Brutal.body(size: 14, color: Brutal.mute)),
          ],
        ),
      );
}
