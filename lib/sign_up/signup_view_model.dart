import 'dart:io';
import 'package:clubship/data/supabase_models/gender.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/sign_up/signup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SignUpStateNotifier extends StateNotifier<SignUpState> {
  final UserRepository userRepository;

  SignUpStateNotifier(this.userRepository) : super(const SignUpState());

  Future<SignUpResult> signup() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final status = await userRepository.signUpWithEmailAndPassword(state);
    state = state.copyWith(
      isLoading: false,
    );
    return status;
  }

  void validate() {
    if (state.name == null) {
      state = state.copyWith(nameError: 'Please enter your name');
    } else {
      state = state.copyWith(nameError: null);
    }
    if (state.userName == null) {
      state =
          state.copyWith(validUserNameMessage: 'Please enter your username');
    } else {
      state = state.copyWith(validUserNameMessage: null);
    }

    if (state.gender == null) {
      state = state.copyWith(genderError: 'Please select you gender');
    } else {
      state = state.copyWith(genderError: null);
    }
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  Future<void> setUsername(String value) async {
    state = state.copyWith(userName: value);
    final result = await userRepository.validUserName(username: value);
    if (!result) {
      state = state.copyWith(validUserNameMessage: 'User name already taken');
    } else {
      state = state.copyWith(validUserNameMessage: null);
    }
  }

  void setFullname(String value) {
    state = state.copyWith(name: value);
  }

  void addImage({required File image}) {
    state = state.copyWith(image: image);
  }
}
