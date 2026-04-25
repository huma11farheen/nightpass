import 'package:clubship/login/login_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_state.freezed.dart';
part 'my_page_state.g.dart';

@freezed
abstract class MyPageState with _$MyPageState {
  const factory MyPageState({
    @Default(true) bool loading,
    String? userName,
    String? emailId,
    @Default(LoginStatus.success) LoginStatus loginStatus,
    String? errorMessage

  }) = _MyPageState;
  factory MyPageState.fromJson(Map<String, dynamic> json) =>
      _$MyPageStateFromJson(json);
}
