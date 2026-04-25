import 'package:clubship/drink_tickets/drink_model/drink_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drink_ticket_model.freezed.dart';
part 'drink_ticket_model.g.dart';


@freezed
abstract class DrinkTicketModel with _$DrinkTicketModel {
  const factory DrinkTicketModel({
    required String ticketId,
    required Drink drink,
    required DateTime ticketExpiryDate,
    required String qrCodeData,
    required String venue,
    String? additionalInformation,
  }) = _DrinkTicketModel;

  factory DrinkTicketModel.fromJson(Map<String, dynamic> json) =>
      _$DrinkTicketModelFromJson(json);

}
