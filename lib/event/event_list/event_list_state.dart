import 'package:clubship/event/event_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_list_state.freezed.dart';
part 'event_list_state.g.dart';

@freezed
abstract class EventListState with _$EventListState {
  const factory EventListState({
    @Default(true) bool loading,
    @Default([]) List<EventViewModel> events,
  }) = _EventListState;

  factory EventListState.fromJson(Map<String, dynamic> json) =>
      _$EventListStateFromJson(json);
}