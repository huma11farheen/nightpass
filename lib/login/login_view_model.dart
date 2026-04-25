import 'package:clubship/login/login_state.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/notifications/notification_service.dart';

import 'package:riverpod/riverpod.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel({required this.userRepository})
      : super(
          const LoginState(),
        );

  final UserRepository userRepository;

  Future<SignInResult> login() async {
    state = state.copyWith(isLoading: true);

    final response = await userRepository.signInWithEmailAndPassword(
        state.email ?? '',  state.password ?? '');

    state = state.copyWith(loginStatus: LoginStatus.success, isLoading: false);

    // Save FCM token after successful login
    if (response == SignInResult.success) {
      try {
        await NotificationService().saveFCMToken();
        // Subscribe to topics
        await NotificationService().subscribeToTopic('events');
      } catch (e) {
        // Don't fail login if notification setup fails
        print('Failed to setup notifications: $e');
      }
    }

    return response;
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    return await userRepository.sendPasswordResetEmail(email: email);
  }
}
