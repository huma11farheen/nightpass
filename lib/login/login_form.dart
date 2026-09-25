import 'package:clubship/design/brutal.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/login/login_view_model.dart';
import 'package:clubship/main_screen/main_landing_page.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:clubship/widgets/video_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final notifier = ref.read(loginProvider.notifier);
    final state = ref.watch(loginProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const VideoBackground(opacity: 0.45),

          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  // ── Scrollable fields ────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // ── Brand ────────────────────────────────────────
                          Text('NIGHTPASS',
                              style: Brutal.label(size: 13, color: Brutal.magenta)),
                          const SizedBox(height: 12),
                          Text('Tokyo\nNights.',
                              style: Brutal.display(size: 52, color: Brutal.paper)),
                          const SizedBox(height: 8),
                          Text("Your pass to Tokyo's premier nightlife.",
                              style: Brutal.body(size: 15, color: Brutal.dim)),

                          const SizedBox(height: 48),

                          // ── Email ─────────────────────────────────────────
                          Text('EMAIL',
                              style: Brutal.label(size: 11, color: Brutal.mute)),
                          const SizedBox(height: 8),
                          ClubTextField(
                            icon: Icons.email_outlined,
                            hintText: 'Enter your email',
                            isEmail: true,
                            onChanged: notifier.setEmail,
                          ),
                          const SizedBox(height: 20),

                          // ── Password ──────────────────────────────────────
                          Text('PASSWORD',
                              style: Brutal.label(size: 11, color: Brutal.mute)),
                          const SizedBox(height: 8),
                          ClubTextField(
                            icon: Icons.lock_outline,
                            hintText: 'Enter your password',
                            isPassword: true,
                            onChanged: notifier.setPassword,
                          ),
                          const SizedBox(height: 12),

                          // ── Forgot password ───────────────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push(Routes.forgetPassword);
                              },
                              child: Text('Forgot Password?',
                                  style: Brutal.label(
                                      size: 11, color: Brutal.magenta)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Pinned bottom ────────────────────────────────────────
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 24),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Brutal.hairlineColor)),
                    ),
                    child: Column(
                      children: [
                        AppButton.primary(
                          isLoading: state.isLoading,
                          text: 'SIGN IN',
                          onPressed: state.isLoading
                              ? () {}
                              : () async {
                                  if (!mounted) return;
                                  final result = await notifier.login();
                                  if (result == SignInResult.success) {
                                    _goHome();
                                  } else if (context.mounted) {
                                    context.showSnackbar(
                                        message: result.description);
                                  }
                                },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?  ",
                                style: Brutal.body(size: 14, color: Brutal.dim)),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push(Routes.registerEmailScreen);
                              },
                              child: Text('Sign Up',
                                  style: Brutal.label(
                                      size: 12, color: Brutal.magenta)),
                            ),
                          ],
                        ),
                      ],
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

  void _goHome() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainLandingPage()),
      );
}
