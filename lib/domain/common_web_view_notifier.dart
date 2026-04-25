import 'package:clubship/domain/common_web_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'common_web_view_notifier.g.dart';

@riverpod
class CommonWebViewNotifier extends _$CommonWebViewNotifier {
  @override
  CommonWebViewModel build() => const CommonWebViewModel();

  void updateCanGoForwardState(bool canGoForward) {
    state = state.copyWith(canGoForward: canGoForward);
  }

  void updateCanGoBackwardState(bool canGoBackward) {
    state = state.copyWith(canGoBackward: canGoBackward);
  }
}
