import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/data/supabase_models/event_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_category_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<EventCategory>> getCategory(Ref ref) {
  final eventsRepository = ref.watch(eventRepositoryProvider);
  return eventsRepository.getCategories();
}