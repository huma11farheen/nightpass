import 'package:clubship/repository/clubs_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ClubRepository clubRepository(Ref ref) => ClubRepository(supabase);
