import 'package:clubship/colors.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String? newPassword;
  String? confirmPassword;
  bool isLoading = false;

  Future<void> _resetPassword() async {
    // Validation
    if (newPassword == null || newPassword!.isEmpty) {
      if (mounted) {
        context.showSnackbar(message: 'Please enter a new password');
      }
      return;
    }

    if (newPassword!.length < 6) {
      if (mounted) {
        context.showSnackbar(message: 'Password must be at least 6 characters');
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (mounted) {
        context.showSnackbar(message: 'Passwords do not match');
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Update the user's password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        context.showSnackbar(
          message: 'Password reset successfully! Please login with your new password.',
        );
        // Navigate to login
        context.go('/login');
      }
    } on AuthException catch (e) {
      if (mounted) {
        context.showSnackbar(message: e.message);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackbar(message: 'Failed to reset password. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Reset Password',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your new password below',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // New Password field
                    Text(
                      'New Password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClubTextField(
                      icon: Icons.lock_outline,
                      hintText: 'Enter new password',
                      isPassword: true,
                      onChanged: (value) {
                        setState(() {
                          newPassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Confirm Password field
                    Text(
                      'Confirm Password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClubTextField(
                      icon: Icons.lock_outline,
                      hintText: 'Confirm new password',
                      isPassword: true,
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Reset button
                    AppButton.primary(
                      text: isLoading ? 'RESETTING...' : 'RESET PASSWORD',
                      onPressed: isLoading ? () {} : _resetPassword,
                    ),
                    const SizedBox(height: 20),

                    // Back to login
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorPallete.brightPink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
