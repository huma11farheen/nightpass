import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum _Step { email, otp, newPassword }

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  _Step _step = _Step.email;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

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
    final error = await ref.read(authRepositoryProvider).verifyOtp(
          email: _emailController.text.trim(),
          otp: otp,
        );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (error != null) {
      context.showSnackbar(message: error);
    } else {
      setState(() => _step = _Step.newPassword);
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
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
      context.showSnackbar(message: 'Password updated successfully');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step == _Step.otp) {
              setState(() => _step = _Step.email);
            } else if (_step == _Step.newPassword) {
              setState(() => _step = _Step.otp);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildStepIndicator(),
              const SizedBox(height: 32),
              if (_step == _Step.email) _buildEmailStep(),
              if (_step == _Step.otp) _buildOtpStep(),
              if (_step == _Step.newPassword) _buildNewPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [_Step.email, _Step.otp, _Step.newPassword];
    return Row(
      children: steps.map((s) {
        final active = s == _step;
        final done = steps.indexOf(s) < steps.indexOf(_step);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: done || active
                  ? ColorPallete.brightPink
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a verification code',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 32),
        ClubTextField(
          controller: _emailController,
          icon: Icons.email_outlined,
          hintText: 'your.email@example.com',
          isEmail: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          text: _isLoading ? 'Sending...' : 'Send Code',
          onPressed: _isLoading ? () {} : _sendOtp,
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Code',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to ${_emailController.text.trim()}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 32),
        ClubTextField(
          controller: _otpController,
          icon: Icons.lock_outline,
          hintText: '000000',
          type: TextInputType.number,
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          text: _isLoading ? 'Verifying...' : 'Verify Code',
          onPressed: _isLoading ? () {} : _verifyOtp,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: Text(
              'Resend Code',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorPallete.brightPink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a strong password for your account',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 32),
        ClubTextField(
          controller: _passwordController,
          icon: Icons.lock_outline,
          hintText: 'New password',
          isPassword: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        ClubTextField(
          controller: _confirmController,
          icon: Icons.lock_outline,
          hintText: 'Confirm new password',
          isPassword: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          text: _isLoading ? 'Updating...' : 'Update Password',
          onPressed: _isLoading ? () {} : _updatePassword,
        ),
      ],
    );
  }
}
