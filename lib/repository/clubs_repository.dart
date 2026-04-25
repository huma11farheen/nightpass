import 'package:clubship/data/supabase_models/club.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubRepository {
  final SupabaseClient supabase;

  ClubRepository(this.supabase);
  Future<List<Club>> getClubs() async {
    final clubs = await supabase
        .from(Club.modelName)
        .select('*')
        .withConverter(
            (data) => data.map((e) => Club.fromJson(e)).toList());

    return clubs;
  }
}
