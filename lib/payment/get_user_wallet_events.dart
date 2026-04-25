import 'package:clubship/data/providers/user_wallet_repository_provider.dart';
import 'package:clubship/data/supabase_models/user_wallet_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_user_wallet_events.g.dart';

@riverpod
Future<List<UserWalletEvent>> getUserWalletEvents(Ref ref) {
  final userWalletRepository = ref.watch(userWalletRepositoryProvider);
  return userWalletRepository.getUserWalletEvents();
}
