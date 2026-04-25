import 'package:clubship/data/supabase_models/gender.dart';
import 'package:clubship/my_page/my_page_state.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel({
    required this.userRepository,
  }) : super(const MyPageState()) {
    initialize();
  }

  final UserRepository userRepository;
  String? _name;
  String? _username;
  Gender? _gender;
  String? _profileImageUrl;

  Future<void> initialize() async {
    await userRepository.getUserDetail();
  }

  Future<void> logout() async {
    await userRepository.logout();
  }

  void updateEmail(String value) {
  }

  void updateName(String value) {
    _name = value;
  }

  void updateUsername(String value) {
    _username = value;
  }

  void updateGender(Gender? gender) {
    _gender = gender;
  }

  void updateProfileImage(String imageUrl) {
    _profileImageUrl = imageUrl;
  }

  Future<bool> checkUsernameAvailability(String username) async {
    return await userRepository.validUserName(username: username);
  }

  Future<void> updateUserProfile(String userId) async {
    await userRepository.updateUserProfile(
      userId: userId,
      name: _name,
      username: _username,
      gender: _gender?.name,


      profileImageUrl: _profileImageUrl,


    );
  }

  // Future<void> update() async {
  //   try {
  //     if (_name.isNotEmpty && _name.compareTo(state.userName ?? '') != 0) {
  //       await userRepository.updateUserName(_name);
  //     }
  //
  //     if (_email.isNotEmpty && _email.compareTo(state.emailId ?? '') != 0) {
  //       await userRepository.updateEmail(_name);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     state = state.copyWith(
  //       loginStatus: LoginStatus.error,
  //       errorMessage: e.code,
  //     );
  //   }
  // }

}
