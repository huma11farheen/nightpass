import 'package:clubship/data/supabase_models/club.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_list_state.freezed.dart';
part 'club_list_state.g.dart';

@freezed
abstract class ClubListState with _$ClubListState {
  const factory ClubListState({
    @Default(true) bool loading,
    @Default([]) List<Club> clubs,
  }) = _ClubListState;

  factory ClubListState.fromJson(Map<String, dynamic> json) =>
      _$ClubListStateFromJson(json);
}
