import 'dart:ui';
import 'package:clubship/colors.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReserveClubScreen extends ConsumerStatefulWidget {
  const ReserveClubScreen({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  ConsumerState<ReserveClubScreen> createState() => _ReserveClubScreenState();
}

class _ReserveClubScreenState extends ConsumerState<ReserveClubScreen> {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _scrollController.dispose();
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
    final openingTime = getHourAndMinute(clubModel.openingTime);
    final closingTime = getHourAndMinute(clubModel.closingTime);

    return userDetails.when(
      data: (user) {
        if (_nameController.text.isEmpty && user?.name != null) {
          _nameController.text = user?.name ?? '';
        }
        if (_emailController.text.isEmpty && user?.contactEmail != null) {
          _emailController.text = user?.contactEmail ?? '';
        }

        if (_submitted) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0A14),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorPallete.brightPink.withValues(alpha: 0.25),
                            Colors.purple.withValues(alpha: 0.25),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorPallete.brightPink.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.check_rounded, color: ColorPallete.brightPink, size: 40),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Request Sent!',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thank you! We\'ve received your VIP table request for ${widget.club.name}. We\'ll be in touch soon.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
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

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A14),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            title: Text(
              'VIP Table Booking',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Hero Image
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(clubModel.image ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.6),
                                  const Color(0xFF0A0A14),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                          // VIP Badge
                          Positioned(
                            top: 100,
                            right: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.amber.withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        'VIP',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.amber,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Club Info
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clubModel.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 13, color: ColorPallete.brightPink),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        clubModel.locationAddress ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.75),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 13, color: Colors.amber),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${openingTime['hour'].toString().padLeft(2, '0')}:${openingTime['minute'].toString().padLeft(2, '0')} – ${closingTime['hour'].toString().padLeft(2, '0')}:${closingTime['minute'].toString().padLeft(2, '0')}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // How it works — step strip
                            _StepStrip(),
                            const SizedBox(height: 32),

                            // Section header
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [ColorPallete.brightPink, Colors.purple],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Your Details',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We\'ll use this to confirm your reservation',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Form fields
                            _FormField(
                              label: 'Full Name',
                              icon: Icons.person_outline_rounded,
                              child: ClubTextField(
                                controller: _nameController,
                                hintText: 'Enter your full name',
                                onChanged: (value) {},
                                isNameField: true,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _FormField(
                              label: 'Email Address',
                              icon: Icons.mail_outline_rounded,
                              child: ClubTextField(
                                controller: _emailController,
                                hintText: 'your.email@example.com',
                                onChanged: (value) {},
                                type: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _FormField(
                              label: 'Contact Number',
                              icon: Icons.phone_outlined,
                              child: ClubTextField(
                                controller: _phoneController,
                                hintText: '+81 90 1234 5678',
                                onChanged: (value) {},
                                type: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _FormField(
                              label: 'Number of Guests',
                              icon: Icons.group_outlined,
                              child: ClubTextField(
                                controller: _guestsController,
                                hintText: 'e.g., 4',
                                onChanged: (value) {},
                                type: TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _FormField(
                              label: 'Special Requests',
                              icon: Icons.notes_rounded,
                              isOptional: true,
                              child: ClubTextField(
                                controller: _notesController,
                                hintText: 'Bottle preferences, seating, occasions...',
                                onChanged: (value) {},
                                maxlines: 3,
                              ),
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A14),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: AppButton.primary(
                  onPressed: () async {
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
                    final subject = Uri.encodeComponent('VIP Table Reservation Request – ${widget.club.name}');
                    final body = Uri.encodeComponent(
                      'Club: ${widget.club.name}\n'
                      'Name: $name\n'
                      'Email: $email\n'
                      'Phone: $phone\n'
                      'Guests: $guests\n'
                      '${notes.isNotEmpty ? 'Special Requests: $notes\n' : ''}'
                      '\nSent via Clubship app',
                    );

                    final uri = Uri.parse('mailto:hum11farheen@gmail.com?subject=$subject&body=$body');
                    await launchUrl(uri);

                    if (context.mounted) {
                      setState(() => _submitted = true);
                    }
                  },
                  text: 'Request Reservation',
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stack) {
        return const Scaffold(
          backgroundColor: Color(0xFF0A0A14),
          body: Center(
            child: Text(
              'Error loading user data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
      loading: () {
        return const Scaffold(
          backgroundColor: Color(0xFF0A0A14),
          body: Center(
            child: CircularProgressIndicator(color: ColorPallete.brightPink),
          ),
        );
      },
    );
  }
}


class _StepStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        children: [
          const _Step(number: '1', label: 'Fill form', icon: Icons.edit_note_rounded),
          _StepDivider(),
          const _Step(number: '2', label: 'We confirm', icon: Icons.phone_in_talk_outlined),
          _StepDivider(),
          const _Step(number: '3', label: 'Enjoy VIP', icon: Icons.celebration_outlined),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _Step({required this.number, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorPallete.brightPink.withValues(alpha: 0.25),
                  Colors.purple.withValues(alpha: 0.25),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorPallete.brightPink.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(icon, color: ColorPallete.brightPink, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: 20,
        child: Divider(
          color: Colors.white.withValues(alpha: 0.15),
          thickness: 1,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final bool isOptional;

  const _FormField({
    required this.label,
    required this.icon,
    required this.child,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: ColorPallete.brightPink.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 6),
              Text(
                'optional',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
