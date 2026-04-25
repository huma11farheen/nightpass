import 'package:clubship/home_page/main_page_state.dart';
import 'package:clubship/repository/events_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPageViewModel extends StateNotifier<MainPageState> {
  final EventsRepository eventsRepository;

  MainPageViewModel({
    required this.eventsRepository,
  }) : super(const MainPageState()) {
    initialize();
  }

  void initialize() {
    getUpcomingEvents();
  }

  void getUpcomingEvents() async {
    // eventsRepository.().listen((eventItems) {
    //   state = state.copyWith(
    //     upcomingEvents: eventItems,
    //   );
    // });
  }
}
