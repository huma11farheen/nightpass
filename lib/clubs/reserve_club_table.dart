import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ReserveClubScreen extends ConsumerStatefulWidget {
  const ReserveClubScreen({super.key, required this.club});

  final Club club;

  @override
  ConsumerState<ReserveClubScreen> createState() => _ReserveClubScreenState();
}

class _ReserveClubScreenState extends ConsumerState<ReserveClubScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubModel = widget.club;
    final userDetails = ref.watch(getUserDetailProvider);

    return userDetails.when(
      data: (user) {
        if (_nameController.text.isEmpty && user?.name != null) {
          _nameController.text = user!.name ?? '';
        }
        if (_emailController.text.isEmpty && user?.contactEmail != null) {
          _emailController.text = user!.contactEmail ?? '';
        }

        if (_submitted) return _SuccessScreen(clubName: widget.club.name);

        return _FormScreen(
          club: clubModel,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          guestsController: _guestsController,
          notesController: _notesController,
          onSubmit: () async {
            final name = _nameController.text.trim();
            final email = _emailController.text.trim();
            final phone = _phoneController.text.trim();
            final guests = _guestsController.text.trim();

            if (name.isEmpty || email.isEmpty || phone.isEmpty || guests.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all required fields')),
              );
              return;
            }

            final notes = _notesController.text.trim();
            final subject = Uri.encodeComponent(
                'VIP Table Reservation Request – ${widget.club.name}');
            final body = Uri.encodeComponent(
              'Club: ${widget.club.name}\n'
              'Name: $name\n'
              'Email: $email\n'
              'Phone: $phone\n'
              'Guests: $guests\n'
              '${notes.isNotEmpty ? 'Special Requests: $notes\n' : ''}'
              '\nSent via Nightpass app',
            );

            final uri = Uri.parse(
                'mailto:hum11farheen@gmail.com?subject=$subject&body=$body');
            await launchUrl(uri);

            if (context.mounted) setState(() => _submitted = true);
          },
        );
      },
      error: (_, __) => Scaffold(
        backgroundColor: Brutal.bg,
        body: Center(
          child: Text('Error loading user data',
              style: Brutal.body(size: 16, color: Brutal.dim)),
        ),
      ),
      loading: () => const Scaffold(
        backgroundColor: Brutal.bg,
        body: Center(child: CircularProgressIndicator(color: Brutal.magenta)),
      ),
    );
  }
}

// ── Success screen ─────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.clubName});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brutal.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: Brutal.yellow.withValues(alpha: 0.1),
                child: const Icon(Icons.check, color: Brutal.yellow, size: 48),
              ),
              const SizedBox(height: 28),
              Text('REQUEST SENT',
                  style: Brutal.display(size: 30, color: Brutal.paper),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'We\'ve received your VIP table request for $clubName. We\'ll be in touch soon.',
                style: Brutal.body(size: 16, color: Brutal.dim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AppButton.primary(
                text: 'Back to Club',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main form screen ───────────────────────────────────────────────────────────

class _FormScreen extends StatelessWidget {
  const _FormScreen({
    required this.club,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.guestsController,
    required this.notesController,
    required this.onSubmit,
  });

  final Club club;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController guestsController;
  final TextEditingController notesController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final openingTime = getHourAndMinute(club.openingTime);
    final closingTime = getHourAndMinute(club.closingTime);

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
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero image with gradient fade ───────────────────────────
                  Stack(
                    children: [
                      SizedBox(
                        height: 420,
                        width: double.infinity,
                        child: Image.network(
                          club.image ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient fade to bg — matches event detail
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
                      // Club name + chips — same overlay style as event detail
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              club.name,
                              style: Brutal.display(size: 30, color: Brutal.paper),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                // Location chip — magenta flat
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
                                      Flexible(
                                        child: Text(
                                          club.locationAddress ?? '',
                                          style: Brutal.label(
                                              size: 10, color: Brutal.paper),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Hours chip — card style
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
                                      const Icon(Icons.access_time,
                                          size: 12, color: Brutal.cyan),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${openingTime['hour'].toString().padLeft(2, '0')}:${openingTime['minute'].toString().padLeft(2, '0')} – ${closingTime['hour'].toString().padLeft(2, '0')}:${closingTime['minute'].toString().padLeft(2, '0')}',
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

                  // ── Body content ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // How it works — styled as _SectionCard
                        const _SectionCard(
                          label: 'How It Works',
                          icon: Icons.info_outline,
                          child: Row(
                            children: [
                              _Step(
                                  number: '1',
                                  label: 'Fill form',
                                  icon: Icons.edit_outlined),
                              _StepArrow(),
                              _Step(
                                  number: '2',
                                  label: 'We confirm',
                                  icon: Icons.phone_outlined),
                              _StepArrow(),
                              _Step(
                                  number: '3',
                                  label: 'Enjoy VIP',
                                  icon: Icons.star_outline),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Your Details form — styled as _SectionCard
                        _SectionCard(
                          label: 'Your Details',
                          icon: Icons.person_outline,
                          child: Column(
                            children: [
                              _FieldRow(
                                label: 'FULL NAME',
                                child: ClubTextField(
                                  controller: nameController,
                                  hintText: 'Enter your full name',
                                  onChanged: (_) {},
                                  isNameField: true,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'EMAIL',
                                child: ClubTextField(
                                  controller: emailController,
                                  hintText: 'your@email.com',
                                  onChanged: (_) {},
                                  type: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'PHONE',
                                child: ClubTextField(
                                  controller: phoneController,
                                  hintText: '+81 90 1234 5678',
                                  onChanged: (_) {},
                                  type: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _FieldRow(
                                label: 'GUESTS',
                                child: ClubTextField(
                                  controller: guestsController,
                                  hintText: 'e.g., 4',
                                  onChanged: (_) {},
                                  type: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Special requests — own section card
                        _SectionCard(
                          label: 'Special Requests',
                          icon: Icons.notes_outlined,
                          trailing: Text('OPTIONAL',
                              style:
                                  Brutal.label(size: 10, color: Brutal.mute)),
                          child: ClubTextField(
                            controller: notesController,
                            hintText:
                                'Bottle preferences, seating, occasions...',
                            onChanged: (_) {},
                            maxlines: 3,
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

          // ── CTA ─────────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Brutal.bg,
              border: Border(top: BorderSide(color: Brutal.hairlineColor)),
            ),
            child: AppButton.primary(
              onPressed: onSubmit,
              text: 'Request Reservation',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card — identical pattern to event detail ──────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.label,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Field row — label above input ─────────────────────────────────────────────

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

// ── Step indicator ────────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  const _Step(
      {required this.number, required this.label, required this.icon});

  final String number;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            color: Brutal.magenta.withValues(alpha: 0.12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Brutal.magenta, size: 18),
                Positioned(
                  top: 3,
                  right: 3,
                  child: Text(number,
                      style: Brutal.label(size: 9, color: Brutal.magenta)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: Brutal.label(size: 11, color: Brutal.dim),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(width: 16, height: 1, color: Brutal.hairlineColor),
    );
  }
}
