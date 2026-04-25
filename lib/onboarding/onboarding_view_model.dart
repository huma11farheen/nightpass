import 'package:clubship/repository/onboarding_repository.dart';
import 'package:flutter/material.dart';

class OnBoardingProvider extends ChangeNotifier {
  OnBoardingProvider() {
    initialize();
  }

  bool _hasShownOnboarding = false;

  bool get hasShownOnboarding => _hasShownOnboarding;

  Future<void> initialize() async {
    _hasShownOnboarding = await OnboardingRepository.hasShownOnboarding();
  }

  Future<void> setOnboardingShown() async {
    _hasShownOnboarding = true;
    await OnboardingRepository.setOnboardingShown();
    notifyListeners();
  }
}
