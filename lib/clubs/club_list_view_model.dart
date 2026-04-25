import 'package:clubship/clubs/club_list_state.dart';
import 'package:clubship/repository/clubs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsViewModel extends StateNotifier<ClubListState> {
  final ClubRepository clubRepository;

  ClubsViewModel(this.clubRepository) : super(const ClubListState()) {
    getClubs();
  }

  Future<void> getClubs() async {
    try {
      print('ClubsViewModel - Fetching clubs...');
      final clubs = await clubRepository.getClubs();
      print('ClubsViewModel - Fetched ${clubs.length} clubs');

      state = state.copyWith(
        clubs: clubs,
        loading: false,
      );
    } catch (e) {
      print('ClubsViewModel - Error fetching clubs: $e');
      state = state.copyWith(
        clubs: [],
        loading: false,
      );
    }
  }
}
