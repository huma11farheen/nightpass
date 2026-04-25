import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_amount_provider.g.dart';

@riverpod
class PaymentAmount extends _$PaymentAmount {
  @override
  int build() => 0;

  void setAmount(int amount) {
    state = amount;
  }

  void reset() {
    state = 0;
  }
}
