import 'package:clubship/repository/ticket_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_repository_provider.g.dart';

@Riverpod(keepAlive: true)
TicketRepository ticketRepository(Ref ref) => TicketRepository(supabase);
