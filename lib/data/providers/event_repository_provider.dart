import 'package:clubship/repository/events_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository_provider.g.dart';

@Riverpod(keepAlive: true)
EventsRepository eventRepository(Ref ref) => EventsRepository(supabase);
