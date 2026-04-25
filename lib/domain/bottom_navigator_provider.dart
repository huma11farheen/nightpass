import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomTabIndex = StateNotifierProvider<BottomTabIndexProvider,int>((ref) => BottomTabIndexProvider());

class BottomTabIndexProvider extends StateNotifier<int> {
  BottomTabIndexProvider() : super(0);

  void setSelectedIndex(int index) {
    state = index;
  }
}
