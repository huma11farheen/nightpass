import 'dart:io';

import 'package:clubship/data/supabase_models/gender.dart';
import 'package:clubship/login/login_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


part 'signup_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    String? email,
    String? password,
    String? name,
    String? userName,
    File? image,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? nameError,
    String? validUserNameMessage,
    String? genderError,
    Gender? gender,
    LoginStatus? loginStatus,
  }) = _SignUpState;

  const SignUpState._();

  bool get isValid =>
      name != null &&
      name!.isNotEmpty &&
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.isNotEmpty &&
      userName != null &&
      userName!.isNotEmpty &&
      gender != null &&
      validUserNameMessage == null;
}
