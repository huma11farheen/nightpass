import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_web_view_model.freezed.dart';
part 'common_web_view_model.g.dart';

@freezed
class CommonWebViewModel with _$CommonWebViewModel {
  const factory CommonWebViewModel({
    @Default(false) bool canGoForward,
    @Default(false) bool canGoBackward,
  }) = _CommonWebViewModel;

  factory CommonWebViewModel.fromJson(Map<String, dynamic> json) =>
      _$CommonWebViewModelFromJson(json);
}
