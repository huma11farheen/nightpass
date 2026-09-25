import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VipScreen extends ConsumerStatefulWidget {
  const VipScreen({super.key, required this.event});

  final EventViewModel event;

  @override
  ConsumerState<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends ConsumerState<VipScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestController = TextEditingController();
  final _contactFocusNode = FocusNode();
  final _guestFocusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guestController.dispose();
    _contactFocusNode.dispose();
    _guestFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToField(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null) {
        Scrollable.ensureVisible(
          node.context!,
          duration: const Duration(milliseconds: 250),
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = ref.watch(getUserDetailProvider);

    return userDetails.when(
      data: (user) => _buildScreen(context, user),
      loading: () => const Scaffold(
        backgroundColor: Brutal.bg,
        body: Center(child: CircularProgressIndicator(color: Brutal.magenta)),
      ),
      error: (_, __) => const Scaffold(backgroundColor: Brutal.bg),
    );
  }

  Widget _buildScreen(BuildContext context, dynamic user) {
    // Pre-fill once with user data
    if (_nameController.text.isEmpty && user?.name != null) {
      _nameController.text = user!.name!;
    }
    if (_emailController.text.isEmpty && user?.contactEmail != null) {
      _emailController.text = user!.contactEmail!;
    }

    final event = widget.event;
    final startDate = DateTime.tryParse(event.startDate);
    final formattedDate = startDate != null
        ? DateFormat('EEEE, MMM dd, yyyy').format(startDate)
        : event.startDate.substring(0, 10);
    final formattedTime =
        startDate != null ? DateFormat('hh:mm a').format(startDate) : '';

    return Scaffold(
      backgroundColor: Brutal.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(forAppBar: true),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            color: Brutal.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text('VIP', style: Brutal.label(size: 12, color: Brutal.bg)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero image — same gradient pattern as event detail ────────
                  Stack(
                    children: [
                      SizedBox(
                        height: 420,
                        width: double.infinity,
                        child: Image.network(
                          event.image,
                          fit: BoxFit.cover,
                          color: Brutal.bg,
                          colorBlendMode: BlendMode.color,
                        ),
                      ),
                      SizedBox(
                        height: 420,
                        width: double.infinity,
                        child: Image.network(
                          event.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Brutal.bg.withValues(alpha: 0.55),
                                Brutal.bg.withValues(alpha: 0.85),
                                Brutal.bg,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Event name + chips overlay
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              event.name,
                              style:
                                  Brutal.display(size: 30, color: Brutal.paper),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  color: Brutal.magenta,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 12, color: Brutal.paper),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.club.name,
                                        style: Brutal.label(
                                            size: 10, color: Brutal.paper),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Brutal.card,
                                    border:
                                        Border.all(color: Brutal.hairlineColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 11, color: Brutal.dim),
                                      const SizedBox(width: 4),
                                      Text(
                                        formattedDate,
                                        style: Brutal.label(
                                            size: 10, color: Brutal.dim),
                                      ),
                                    ],
                                  ),
                                ),
                                if (formattedTime.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Brutal.card,
                                      border: Border.all(
                                          color: Brutal.hairlineColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 11, color: Brutal.cyan),
                                        const SizedBox(width: 4),
                                        Text(
                                          formattedTime,
                                          style: Brutal.label(
                                              size: 10, color: Brutal.dim),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Body ─────────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // VIP Guest Information section card
                        _SectionCard(
                          label: 'VIP Guest Information',
                          icon: Icons.star_outline,
                          child: Column(
                            children: [
                              _FieldRow(
                                label: 'NAME',
                                child: ClubTextField(
                                  controller: _nameController,
                                  hintText: 'Your full name',
                                  onChanged: (_) {},
                                  isNameField: true,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'EMAIL',
                                child: ClubTextField(
                                  controller: _emailController,
                                  hintText: 'Email address',
                                  onChanged: (_) {},
                                  type: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'EVENT DATE',
                                child: ClubTextField(
                                  initialText: event.startDate.substring(0, 10),
                                  hintText: 'Event date',
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'CONTACT NUMBER',
                                child: ClubTextField(
                                  controller: _phoneController,
                                  focusNode: _contactFocusNode,
                                  hintText: 'Phone number',
                                  onTap: () => _scrollToField(_contactFocusNode),
                                  onChanged: (_) {},
                                  type: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'NUMBER OF GUESTS',
                                child: ClubTextField(
                                  controller: _guestController,
                                  focusNode: _guestFocusNode,
                                  hintText: 'Total guests',
                                  onTap: () {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _scrollToField(_guestFocusNode);
                                    });
                                  },
                                  onChanged: (_) {},
                                  type: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Brutal.yellow.withValues(alpha: 0.08),
                            border: Border.all(
                                color: Brutal.yellow.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Brutal.yellow, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Once we receive your request, we will contact you via email or phone. Please check your inbox.',
                                  style:
                                      Brutal.body(size: 15, color: Brutal.yellow),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── CTA ──────────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Brutal.bg,
              border: Border(top: BorderSide(color: Brutal.hairlineColor)),
            ),
            child: AppButton.primary(
              isLoading: _loading,
              onPressed: () async {
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                final phone = _phoneController.text.trim();
                final guests = _guestController.text.trim();

                if (name.isEmpty || email.isEmpty || phone.isEmpty || guests.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Brutal.elevated,
                    ),
                  );
                  return;
                }

                setState(() => _loading = true);

                try {
                  await supabase.functions.invoke(
                    'send-vip-request',
                    body: {
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'guests': guests,
                      'eventName': event.name,
                      'venueName': event.club.name,
                      'eventDate': event.startDate.substring(0, 10),
                    },
                  );
                  if (context.mounted) {
                    await showCustomAlertDialog(
                      context: context,
                      title: 'Request Sent',
                      message: 'Your VIP table request has been submitted. We will contact you shortly.',
                      onConfirm: () => Navigator.of(context).pop(),
                    );
                  }
                } catch (e) {
                  debugPrint('VIP request error: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
              text: 'Send VIP Request',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brutal.bg,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 2, height: 18, color: Brutal.magenta),
              const SizedBox(width: 10),
              Icon(icon, size: 16, color: Brutal.magenta),
              const SizedBox(width: 8),
              Text(label,
                  style: Brutal.display(size: 18, color: Brutal.paper)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Field row ─────────────────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Brutal.label(size: 11, color: Brutal.mute)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// Keep PriceTag for any other screens that may reference it
class PriceTag extends StatelessWidget {
  final String price;

  const PriceTag({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Brutal.magenta,
      child: Text(
        price == '0' ? 'FREE' : '¥$price',
        style: Brutal.label(size: 12, color: Brutal.paper),
      ),
    );
  }
}
