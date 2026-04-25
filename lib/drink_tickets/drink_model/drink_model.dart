import 'package:freezed_annotation/freezed_annotation.dart';

part 'drink_model.freezed.dart';
part 'drink_model.g.dart';

@freezed
abstract class Drink with _$Drink {
  const factory Drink({
    required String name,
    required String category,
    required double price,
    @Default('') String description,
  }) = _Drink;

  factory Drink.fromJson(Map<String, dynamic> json) => _$DrinkFromJson(json);
}
