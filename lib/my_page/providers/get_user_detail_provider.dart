import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_user_detail_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserProfile?> getUserDetail(Ref ref) {
  final userRepository = ref.watch(authRepositoryProvider);
  return userRepository.getUserDetail();
}