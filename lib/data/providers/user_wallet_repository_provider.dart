import 'package:clubship/repository/user_wallet_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_wallet_repository_provider.g.dart';

@Riverpod(keepAlive: true)
UserWalletRepository userWalletRepository(Ref ref) => UserWalletRepository(supabase);
