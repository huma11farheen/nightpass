import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_item.freezed.dart';
part 'event_item.g.dart';



@freezed
class EventItem with _$EventItem {
  const factory EventItem({
    required String imageUrl,
    required String eventName,
    required String description,
    required String location,
    String? startDate,
    String? endDate,
    required String womenPrice,
    required String menPrice,
    @Default('0') String pending,
    @Default('0') String checkIn,
    @Default([]) List<String> subImages,
  }) = _EventItem;

  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);

}
