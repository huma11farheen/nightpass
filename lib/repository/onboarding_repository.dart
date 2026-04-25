import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const String _onboardingKey = 'onboardingShown';

  static Future<bool> hasShownOnboarding() async {
    return false;
      //prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

}
