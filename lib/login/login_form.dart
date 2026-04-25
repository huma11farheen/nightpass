import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/login/login_view_model.dart';
import 'package:clubship/main_screen/main_landing_page.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'login_state.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(userRepository: ref.read(authRepositoryProvider)),
);



class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final loginProviderNotifier = ref.read(loginProvider.notifier);
    final state = ref.watch(loginProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            // Animated gradient background
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

            // Floating circles background decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColorPallete.brightPink.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [



                            const SizedBox(height: 40),

                            // Welcome text
                            Text(
                              'Welcome to ',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'NightPass',
                              style: GoogleFonts.outfit(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.pinkAccent,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Gateway to Tokyo\'s Premier Nightlife',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white,
                                //ColorPallete.brightPink.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sign in to access exclusive club events, VIP tables, and seamless digital ticketing.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Feature highlights
                            _buildFeatureRow(
                              icon: Icons.confirmation_number_rounded,
                              text: 'Instant Digital Tickets',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureRow(
                              icon: Icons.star_rounded,
                              text: 'Exclusive VIP Access',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureRow(
                              icon: Icons.local_bar_rounded,
                              text: 'Complimentary Drink Tickets',
                            ),
                            const SizedBox(height: 40),

                            // Email field
                            Text(
                              'Email',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClubTextField(
                              icon: Icons.email_outlined,
                              hintText: 'Enter your email',
                              isEmail: true,
                              onChanged: loginProviderNotifier.setEmail,
                            ),
                            const SizedBox(height: 24),

                            // Password field
                            Text(
                              'Password',
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
                              hintText: 'Enter your password',
                              isPassword: true,
                              onChanged: loginProviderNotifier.setPassword,
                            ),
                            const SizedBox(height: 16),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  context.push(Routes.forgetPassword);
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.brightPink,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                      // Login button
                      AppButton.primary(
                        text: state.isLoading ? 'SIGNING IN...' : 'SIGN IN',
                        onPressed: !state.isLoading
                            ? () async {
                                if (!mounted) return;
                                final result = await loginProviderNotifier.login();
                                if (result == SignInResult.success) {
                                  navigateToMainLandingPage();
                                } else {
                                  if (context.mounted) {
                                    context.showSnackbar(message: result.description);
                                  }
                                }
                              }
                            : () {},
                      ),
                      const SizedBox(height: 20),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.push(Routes.registerEmailScreen);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ColorPallete.brightPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ColorPallete.cardColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPallete.brightPink.withValues(alpha: 0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: ColorPallete.brightPink,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Signing you in...',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  //  Helper widgets
  // ------------------------------------------------------------------------
  Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorPallete.brightPink.withValues(alpha: 0.2),
                Colors.purple.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: ColorPallete.brightPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          size: 18,
          color: Colors.green.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------------
  //  Navigation helpers
  // ------------------------------------------------------------------------
  void navigateToMainLandingPage() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MainLandingPage()),
  );
}