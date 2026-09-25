import 'package:clubship/repository/venue_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final venueRepositoryProvider = Provider<VenueRepository>(
  (ref) => VenueRepository(supabase),
);
