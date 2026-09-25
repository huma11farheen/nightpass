import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/send_tickets/state/send_ticket_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendEventTicketViewModel extends StateNotifier<SendTicketState> {
  final UserRepository authRepository;

  SendEventTicketViewModel(
    this.authRepository,
  ) : super(const SendTicketState());

  Future<void> getUsers(String query) async {
    final users = await authRepository.searchUsers(query);
    state = state.copyWith(users: users, isLoading: false);
  }

  Future<void> setSelectedUser(UserProfile user) async {
    final currentUser = state.selectedUser;
    if (currentUser == user) {
      state = state.copyWith(
        selectedUser: null,
      );
    } else {
      state = state.copyWith(
        selectedUser: user,
      );
    }
  }

  Future<bool> sendTicket({required String ticketId}) async {
    state = state.copyWith(isLoading: true);
    final sent = await authRepository.sendTicket(
        ticketId: ticketId,
        receiverId: state.selectedUser?.id ?? '',
        isEventTicket: true);
    state = state.copyWith(isLoading: false);
    return sent;
  }

  void reset() {
    state = const SendTicketState();
  }
}

final sendTicketViewModel =
    StateNotifierProvider<SendEventTicketViewModel, SendTicketState>(
  (ref) {
    return SendEventTicketViewModel(ref.read(authRepositoryProvider));
  },
);
