import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _fade;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

    _checkAuthState();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    final userRepository = ref.read(authRepositoryProvider);
    // Give animations at least 1.2s to breathe
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final isLoggedIn = userRepository.currentUser != null;
    if (isLoggedIn) {
      context.pushReplacement(Routes.mainLandingScreen);
    } else {
      context.pushReplacement(Routes.loginSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Radial glow behind logo
            Center(
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Brutal.magenta.withValues(alpha: _glowAnim.value * 0.25),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Logo
            Center(
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, child) => Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
                child: AppIcons.logo(size: 64, color: Brutal.paper),
              ),
            ),

            // Brand name + tagline at bottom
            Positioned(
              bottom: 48 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'NIGHTPASS',
                    textAlign: TextAlign.center,
                    style: Brutal.label(size: 13, color: Brutal.magenta),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tokyo\'s Premier Nightlife',
                    textAlign: TextAlign.center,
                    style: Brutal.body(size: 13, color: Brutal.mute),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
