import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/widgets/video_background.dart';
import 'package:clubship/design/brutal.dart';

import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/sign_up/signup_state.dart';
import 'package:clubship/sign_up/signup_view_model.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/supabase_models/gender.dart';

final signUpProviderNotifier =
    StateNotifierProvider<SignUpStateNotifier, SignUpState>(
  (ref) => SignUpStateNotifier(ref.read(authRepositoryProvider)),
);

class RegisterProfileScreen extends ConsumerStatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  ConsumerState<RegisterProfileScreen> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<RegisterProfileScreen> {
  final _scroll        = ScrollController();
  final _fullNameNode  = FocusNode();
  final _usernameNode  = FocusNode();
  final _emailNode     = FocusNode();
  final _passwordNode  = FocusNode();
  final _otpController = TextEditingController();
  final _otpNode       = FocusNode();

  // 1 = profile, 2 = credentials, 3 = OTP verification
  int _step = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(signUpProviderNotifier);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _fullNameNode.dispose();
    _usernameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _otpController.dispose();
    _otpNode.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null) {
        Scrollable.ensureVisible(node.context!,
            alignment: 0.2, duration: const Duration(milliseconds: 250));
      }
    });
  }

  Future<void> _submitCredentials() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    final notifier = ref.read(signUpProviderNotifier.notifier);
    final error = await notifier.signUpAndSendOtp();
    if (!mounted) return;
    if (error != null) {
      context.showSnackbar(message: error);
    } else {
      _otpController.clear();
      setState(() => _step = 3);
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      context.showSnackbar(message: 'Please enter the 6-digit code');
      return;
    }
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    final notifier = ref.read(signUpProviderNotifier.notifier);
    final error = await notifier.verifyOtpAndCreate(otp);
    if (!mounted) return;
    if (error != null) {
      context.showSnackbar(message: error);
    } else {
      context.showSnackbar(message: 'Welcome to NightPass!');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.go(Routes.mainLandingScreen);
    }
  }

  Future<void> _resendOtp() async {
    final notifier = ref.read(signUpProviderNotifier.notifier);
    final error = await notifier.signUpAndSendOtp();
    if (!mounted) return;
    context.showSnackbar(
      message: error ?? 'Code resent to your email',
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier  = ref.read(signUpProviderNotifier.notifier);
    final state     = ref.watch(signUpProviderNotifier);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final headings = ['Who\nAre You?', 'Your\nCredentials', 'Verify\nYour Email'];
    final subtitles = [
      'Set up your NightPass profile.',
      'How you\'ll sign in every time.',
      'Enter the 6-digit code sent to ${state.email ?? 'your email'}.',
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const VideoBackground(opacity: 0.40),

          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── Top bar ──────────────────────────────────────────
                          Row(
                            children: [
                              AppBackButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  if (_step > 1) {
                                    setState(() => _step--);
                                  } else {
                                    context.pop();
                                  }
                                },
                              ),
                              const Spacer(),
                              _StepDot(active: _step == 1, done: _step > 1),
                              const SizedBox(width: 6),
                              _StepDot(active: _step == 2, done: _step > 2),
                              const SizedBox(width: 6),
                              _StepDot(active: _step == 3, done: false),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ── Brand ────────────────────────────────────────────
                          Text('NIGHTPASS',
                              style: Brutal.label(size: 13, color: Brutal.magenta)),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Align(
                              key: ValueKey(_step),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                headings[_step - 1],
                                style: Brutal.display(size: 52, color: Brutal.paper),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Align(
                              key: ValueKey('sub$_step'),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                subtitles[_step - 1],
                                style: Brutal.body(size: 15, color: Brutal.dim),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ── Step 1: Profile ──────────────────────────────────
                          if (_step == 1) ...[
                            Text('FULL NAME',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              focusNode: _fullNameNode,
                              onTap: () => _ensureVisible(_fullNameNode),
                              icon: Icons.person_outline,
                              hintText: 'Your full name',
                              onChanged: notifier.setFullname,
                            ),
                            if (state.nameError != null) ...[
                              const SizedBox(height: 6),
                              Text(state.nameError!,
                                  style: Brutal.label(size: 11, color: Colors.red)),
                            ],

                            const SizedBox(height: 20),

                            Text('USERNAME',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              focusNode: _usernameNode,
                              onTap: () => _ensureVisible(_usernameNode),
                              icon: Icons.alternate_email,
                              hintText: 'Choose a username',
                              onChanged: notifier.setUsername,
                            ),
                            if (state.validUserNameMessage != null) ...[
                              const SizedBox(height: 6),
                              Text(state.validUserNameMessage!,
                                  style: Brutal.label(size: 11, color: Colors.red)),
                            ],

                            const SizedBox(height: 20),

                            Text('GENDER',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            _GenderSelector(onChanged: notifier.setGender),
                            if (state.genderError != null) ...[
                              const SizedBox(height: 6),
                              Text(state.genderError!,
                                  style: Brutal.label(size: 11, color: Colors.red)),
                            ],

                            const SizedBox(height: 40),

                            AppButton.primary(
                              text: 'CONTINUE',
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                FocusScope.of(context).unfocus();
                                setState(() => _step = 2);
                                _scroll.animateTo(0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              },
                            ),
                          ],

                          // ── Step 2: Credentials ──────────────────────────────
                          if (_step == 2) ...[
                            AutofillGroup(
                              onDisposeAction: AutofillContextAction.cancel,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('EMAIL',
                                      style: Brutal.label(size: 11, color: Brutal.mute)),
                                  const SizedBox(height: 8),
                                  ClubTextField(
                                    focusNode: _emailNode,
                                    onTap: () => _ensureVisible(_emailNode),
                                    icon: Icons.email_outlined,
                                    hintText: 'Enter your email',
                                    isEmail: true,
                                    onChanged: notifier.setEmail,
                                  ),

                                  const SizedBox(height: 20),

                                  Text('PASSWORD',
                                      style: Brutal.label(size: 11, color: Brutal.mute)),
                                  const SizedBox(height: 8),
                                  ClubTextField(
                                    focusNode: _passwordNode,
                                    onTap: () => _ensureVisible(_passwordNode),
                                    icon: Icons.lock_outline,
                                    hintText: 'Create a password',
                                    isPassword: true,
                                    onChanged: notifier.setPassword,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            AppButton.primary(
                              isLoading: state.isLoading,
                              text: 'SEND CODE',
                              onPressed: state.isLoading || !state.isValid
                                  ? () {}
                                  : _submitCredentials,
                            ),
                          ],

                          // ── Step 3: OTP ──────────────────────────────────────
                          if (_step == 3) ...[
                            Text('6-DIGIT CODE',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              controller: _otpController,
                              focusNode: _otpNode,
                              onTap: () => _ensureVisible(_otpNode),
                              icon: Icons.pin_outlined,
                              hintText: '000000',
                              type: TextInputType.number,
                              onChanged: (_) {},
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: state.isLoading ? null : _resendOtp,
                              child: Text(
                                'Resend code',
                                style: Brutal.label(size: 12, color: Brutal.magenta),
                              ),
                            ),

                            const SizedBox(height: 40),

                            AppButton.primary(
                              isLoading: state.isLoading,
                              text: 'VERIFY & CREATE ACCOUNT',
                              onPressed: state.isLoading ? () {} : _verifyOtp,
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Sign in link ─────────────────────────────────────
                          if (_step < 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account?  ',
                                    style: Brutal.body(size: 14, color: Brutal.dim)),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.pop();
                                  },
                                  child: Text('Sign In',
                                      style: Brutal.label(
                                          size: 12, color: Brutal.magenta)),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step dot indicator ──────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.done});
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: active ? 20 : 6,
        height: 6,
        color: (active || done) ? Brutal.magenta : Brutal.elevated,
      );
}

// ── Gender selector ─────────────────────────────────────────────────────────────

class _GenderSelector extends StatefulWidget {
  const _GenderSelector({required this.onChanged});
  final void Function(Gender) onChanged;

  @override
  State<_GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<_GenderSelector> {
  Gender? _selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Gender.values.map((g) {
        final isSelected = _selected == g;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selected = g);
              widget.onChanged(g);
            },
            child: Container(
              margin: EdgeInsets.only(right: g != Gender.values.last ? 1 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: isSelected ? Brutal.magenta : Brutal.elevated,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    g == Gender.male ? Icons.male : Icons.female,
                    size: 16,
                    color: isSelected ? Brutal.paper : Brutal.mute,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g.name.toUpperCase(),
                    style: Brutal.label(
                        size: 12,
                        color: isSelected ? Brutal.paper : Brutal.mute),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
