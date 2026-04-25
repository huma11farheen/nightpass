import 'dart:io';
import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/router.dart';
import 'package:clubship/sign_up/signup_state.dart';
import 'package:clubship/sign_up/signup_view_model.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:clubship/widgets/drop_down_selector.dart';
import 'package:clubship/widgets/image_picker.dart';
import 'package:clubship/widgets/sncakbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/supabase_models/gender.dart';

final signUpProviderNotifier =
    StateNotifierProvider<SignUpStateNotifier, SignUpState>(
  (ref) {
    return SignUpStateNotifier(ref.read(authRepositoryProvider));
  },
);

class RegisterProfileScreen extends ConsumerStatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  ConsumerState<RegisterProfileScreen> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<RegisterProfileScreen> {
  final _scroll = ScrollController();
  final _fullNameNode   = FocusNode();
  final _usernameNode   = FocusNode();
  final _genderNode     = FocusNode(); // only if DropDown needs it
  final _emailNode      = FocusNode();
  final _passwordNode   = FocusNode();
  File? _image;


  @override
  void dispose() {
    _scroll.dispose();
    _fullNameNode.dispose();
    _usernameNode.dispose();
    _genderNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    // wait for keyboard animation & layout pass
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.2,                       // keep field a bit below top
          duration: const Duration(milliseconds: 250),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final signupProviderNotifier = ref.read(signUpProviderNotifier.notifier);
    final state = ref.watch(signUpProviderNotifier);

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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Back button
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.pop();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 24,
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),

                            const SizedBox(height: 20),

                            // Welcome text
                            Text(
                              'Create Your',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'NightPass Account',
                              style: GoogleFonts.outfit(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Colors.pinkAccent,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Join Tokyo\'s most exclusive nightlife community',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () async {
                          showImageSourceBottomSheet(
                            context,
                            (image) {
                              signupProviderNotifier.addImage(image: image);
                              setState(() {
                                _image = image;
                              });
                            },
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                //borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey[600]!,
                                ),
                                image: _image != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(_image!.path),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            const Positioned.fill(
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Full name field
                      Text(
                        'Full Name',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClubTextField(
                        focusNode: _fullNameNode,
                        onTap: () => _ensureVisible(_fullNameNode),
                        icon: Icons.person_outline,
                        hintText: 'Enter your full name',
                        onChanged: (value) {
                          signupProviderNotifier.setFullname(value);
                        },
                      ),
                      if (state.nameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            state.nameError!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.red.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Username field
                      Text(
                        'Username',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClubTextField(
                        onTap: () => _ensureVisible(_usernameNode),
                        focusNode: _usernameNode,
                        icon: Icons.alternate_email,
                        hintText: 'Choose a username',
                        onChanged: (value) {
                          signupProviderNotifier.setUsername(value);
                        },
                      ),
                      if (state.validUserNameMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            state.validUserNameMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.red.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Gender field
                      Text(
                        'Gender',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap:()=>  _ensureVisible(_genderNode) ,
                        child: DropDownSelector<Gender>(
                          isRequired: true,
                          labelText: 'Gender',
                          values: Gender.values,
                          initialValue: null,
                          labels: Gender.values.map((v) => v.name).toList(),
                          onChanged: (value) {
                            signupProviderNotifier.setGender(value);
                          },
                        ),
                      ),
                      if (state.genderError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            state.genderError!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.red.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

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
                        focusNode: _emailNode,
                        onTap: () => _ensureVisible(_emailNode),
                        icon: Icons.email_outlined,
                        hintText: 'Enter your email',
                        isEmail: true,
                        onChanged: (value) {
                          signupProviderNotifier.setEmail(value);
                        },
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
                        focusNode: _passwordNode,
                        onTap: () => _ensureVisible(_passwordNode),
                        icon: Icons.lock_outline,
                        hintText: 'Create a password',
                        isPassword: true,
                        onChanged: (value) {
                          signupProviderNotifier.setPassword(value);
                        },
                      ),
                      const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Bottom section with register button
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Column(
                        children: [
                          // Register button
                          AppButton.primary(
                            text: state.isLoading ? 'CREATING ACCOUNT...' : 'CREATE ACCOUNT',
                            onPressed: !state.isLoading && state.isValid
                                ? () async {
                                    if (!mounted) return;
                                    final result = await signupProviderNotifier.signup();
                                    if (result == SignUpResult.success) {
                                      if (context.mounted) {
                                        context.showSnackbar(
                                          message: 'Welcome to NightPass! Your account has been created.',
                                        );
                                        await Future.delayed(const Duration(seconds: 1));
                                        if (context.mounted) {
                                          context.go(Routes.mainLandingScreen);
                                        }
                                      }
                                    } else if (context.mounted) {
                                      context.showSnackbar(message: result.description);
                                    }
                                  }
                                : () {},
                          ),
                          const SizedBox(height: 20),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  context.pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPallete.brightPink,
                                  ),
                                ),
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
                              'Creating your account...',
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

  void navigateToHomeScreen() {
    context.push(Routes.mainLandingScreen);
  }
}
