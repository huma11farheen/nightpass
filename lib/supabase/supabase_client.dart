import 'package:clubship/supabase/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> configureSupabase() async {
  final url = Config.get('SUPABASE_URL');
  await Supabase.initialize(
    debug: false,
    url: url,
    anonKey: Config.get('SUPABASE_ANON_KEY'),
  );
}
