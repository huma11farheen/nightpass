
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

@JsonSerializable()
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(false) bool loading,
  }) = _PaymentState;
}
