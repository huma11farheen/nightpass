import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_ticket_state.freezed.dart';

@freezed
class SendTicketState with _$SendTicketState {
  const factory SendTicketState({
    @Default([]) List<UserProfile> users,
    UserProfile? selectedUser,
    @Default(false) bool isLoading,
  }) = _SendTicketState;


}
