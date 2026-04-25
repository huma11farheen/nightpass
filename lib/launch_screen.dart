import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final userRepository = ref.read(authRepositoryProvider);
    await Future.delayed(
      const Duration(seconds: 1),
    );

    bool isLoggedIn = userRepository.currentUser != null;
    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      navigateToHomeScreen();
    } else {
      navigateToLoginScreen();
    }
  }

  void navigateToLoginScreen() {
    context.pushReplacement(Routes.loginSelection);
  }

  void navigateToHomeScreen() {
    context.pushReplacement(Routes.mainLandingScreen);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AppIcons.logo(),
      ),
    );
  }
}
