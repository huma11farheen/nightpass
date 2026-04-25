import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_ticket_model.freezed.dart';
part 'event_ticket_model.g.dart';

@freezed
abstract class EventTicketModel with _$EventTicketModel {
  const factory EventTicketModel({
    required String ticketId,
    required DateTime ticketExpiryDate,
    required String qrCodeData,
    required String venue,
    required String eventName,
    String? additionalInformation,
  }) = _EventTicketModel;

  factory EventTicketModel.fromJson(Map<String, dynamic> json) =>
      _$EventTicketModelFromJson(json);
}
