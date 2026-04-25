import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState(
      {String? email,
      String? password,
      @Default(false) bool isLoading,
      String? errorMessage,
      LoginStatus? loginStatus}) = _LoginState;
}

enum LoginStatus { success, error }
