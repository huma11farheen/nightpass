import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:clubship/widgets/video_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _Step { email, otp, newPassword }

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  _Step _step = _Step.email;
  bool _isLoading = false;

  final _emailController    = TextEditingController();
  final _otpController      = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      context.showSnackbar(message: 'Please enter your email');
      return;
    }
    setState(() => _isLoading = true);
    final error = await ref.read(authRepositoryProvider).sendOtpForPasswordReset(email: email);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (error != null) {
      context.showSnackbar(message: error);
    } else {
      setState(() => _step = _Step.otp);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      context.showSnackbar(message: 'Please enter the 6-digit code');
      return;
    }
    setState(() => _isLoading = true);
    // Set flag before verifyOTP creates a session, so the router redirect is suppressed
    authStateNotifier.beginPasswordRecovery();
    debugPrint('🔑 beginPasswordRecovery called, isRecovery=${authStateNotifier.isPasswordRecovery}');
    final error = await ref.read(authRepositoryProvider).verifyOtp(
          email: _emailController.text.trim(),
          otp: otp,
        );
    debugPrint('🔑 verifyOtp returned: error=$error, mounted=$mounted, isRecovery=${authStateNotifier.isPasswordRecovery}');
    setState(() => _isLoading = false);
    if (!mounted) {
      debugPrint('🔑 widget unmounted after verifyOtp — navigation already happened!');
      return;
    }
    if (error != null) {
      authStateNotifier.endPasswordRecovery();
      context.showSnackbar(message: error);
    } else {
      setState(() => _step = _Step.newPassword);
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirm  = _confirmController.text.trim();
    if (password.isEmpty) {
      context.showSnackbar(message: 'Please enter a new password');
      return;
    }
    if (password.length < 6) {
      context.showSnackbar(message: 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      context.showSnackbar(message: 'Passwords do not match');
      return;
    }
    setState(() => _isLoading = true);
    final error = await ref.read(authRepositoryProvider).updatePassword(newPassword: password);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (error != null) {
      context.showSnackbar(message: error);
    } else {
      authStateNotifier.endPasswordRecovery();
      context.showSnackbar(message: 'Password updated successfully');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const VideoBackground(opacity: 0.35),

          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          AppBackButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (_step == _Step.otp) {
                                setState(() => _step = _Step.email);
                              } else if (_step == _Step.newPassword) {
                                setState(() => _step = _Step.otp);
                              } else {
                                context.pop();
                              }
                            },
                          ),

                          const SizedBox(height: 32),

                          // Step dots
                          Row(
                            children: _Step.values.map((s) {
                              final active = s == _step;
                              final done = _Step.values.indexOf(s) <
                                  _Step.values.indexOf(_step);
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  height: 3,
                                  color: done || active
                                      ? Brutal.magenta
                                      : Brutal.elevated,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // Brand
                          Text('NIGHTPASS',
                              style: Brutal.label(size: 13, color: Brutal.magenta)),
                          const SizedBox(height: 12),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Align(
                              key: ValueKey(_step),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _step == _Step.email
                                    ? 'Forgot\nPassword?'
                                    : _step == _Step.otp
                                        ? 'Enter\nYour Code'
                                        : 'New\nPassword',
                                style: Brutal.display(size: 48, color: Brutal.paper),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            _step == _Step.email
                                ? "We'll send a 6-digit code to your email."
                                : _step == _Step.otp
                                    ? 'Check ${_emailController.text.trim()} for your code.'
                                    : 'Choose a strong password.',
                            style: Brutal.body(size: 15, color: Brutal.dim),
                          ),

                          const SizedBox(height: 40),

                          // ── Step 1: Email ──────────────────────────────────
                          if (_step == _Step.email) ...[
                            Text('EMAIL',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              hintText: 'Enter your email',
                              isEmail: true,
                              onChanged: (_) {},
                            ),
                          ],

                          // ── Step 2: OTP ────────────────────────────────────
                          if (_step == _Step.otp) ...[
                            Text('6-DIGIT CODE',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              controller: _otpController,
                              icon: Icons.pin_outlined,
                              hintText: '000000',
                              type: TextInputType.number,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _isLoading ? null : _sendOtp,
                              child: Text(
                                'Resend code',
                                style: Brutal.label(size: 12, color: Brutal.magenta),
                              ),
                            ),
                          ],

                          // ── Step 3: New password ───────────────────────────
                          if (_step == _Step.newPassword) ...[
                            Text('NEW PASSWORD',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              hintText: 'Create new password',
                              isPassword: true,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 20),
                            Text('CONFIRM PASSWORD',
                                style: Brutal.label(size: 11, color: Brutal.mute)),
                            const SizedBox(height: 8),
                            ClubTextField(
                              controller: _confirmController,
                              icon: Icons.lock_outline,
                              hintText: 'Confirm new password',
                              isPassword: true,
                              onChanged: (_) {},
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Pinned bottom button
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 24),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Brutal.hairlineColor)),
                    ),
                    child: AppButton.primary(
                      isLoading: _isLoading,
                      text: _step == _Step.email
                          ? 'SEND CODE'
                          : _step == _Step.otp
                              ? 'VERIFY CODE'
                              : 'UPDATE PASSWORD',
                      onPressed: _isLoading
                          ? () {}
                          : _step == _Step.email
                              ? _sendOtp
                              : _step == _Step.otp
                                  ? _verifyOtp
                                  : _updatePassword,
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
