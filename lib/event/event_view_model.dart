import 'package:clubship/data/supabase_models/club.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_view_model.freezed.dart';
part 'event_view_model.g.dart';

@freezed
class EventViewModel with _$EventViewModel {
  const factory EventViewModel({
    required String id,
    required String createdAt,
    required String name,
    required String image,
     String? description,
    required double femalePrice,
    required String startDate,
    required String endDate,
    @Default([])List<String> subImages,
    @Default([])List<String> category,
    @Default(0) int pending,
    @Default(0) int checkedIn,
    String? clubId,
    @Default(0.0) double malePrice,
    @Default(false)bool isRecurring,
    required String locationAddress,
    @Default(0) int freeFemaleDrinkTicket,
    @Default(0) int freeMaleDrinkTicket,
    @Default(0) int registeredGuestlist,
    @Default(0) int gustlist,
    @Default(false) bool payAtTheDoor,
    @Default(false) bool isServiceTaxIncluded,
    required Club club,
  }) = _EventViewModel;

  factory EventViewModel.fromJson(Map<String, dynamic> json) =>
      _$EventViewModelFromJson(json);

}
