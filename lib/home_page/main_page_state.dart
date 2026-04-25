import 'package:clubship/data/supabase_models/event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_page_state.freezed.dart';

@JsonSerializable()
@freezed
class MainPageState with _$MainPageState {
  const factory MainPageState({
    @Default(true) bool loading,
    @Default([]) List<Event> upcomingEvents,
    @Default([]) List<Event> previousEvents,
  }) = _MainPageState;
}
