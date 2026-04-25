


enum TicketType { entry, drink }
//
// class PaymentViewModel extends StateNotifier<PaymentState> {
//   PaymentViewModel({
//     required this.userRepository,
//     required this.ticketRepository,
//   }) : super(const PaymentState());
//
//   final TicketRepository ticketRepository;
//   final UserRepository userRepository;
//
//   String generateDrinkTicketData() {
//     return '';
//     // Generate a unique identifier for the drink ticket
//    // final ticketId = const Uuid().v4();
//
//     // You can include additional information about the ticket, such as the drink type, expiration date, etc.
//     // String userId = userRepository.userId();
//     //
//     // final expirationDate = DateTime.now();
//     //
//     // // Combine the ticket information into a single string
//     // final ticketData = '$ticketId|$userId|$expirationDate';
//
//    // return ticketData;
//   }
//
//   Future<void> buyTicket(
//       {required int maleTicketCount,
//       required int femaleTicketCount,
//       required EventItem eventItem}) async {
//     final List<String> listQr = [];
//
//     for (int i = 1; i <= maleTicketCount; i++) {
//       listQr.add(generateDrinkTicketData());
//     }
//     for (int i = 1; i <= femaleTicketCount; i++) {
//       listQr.add(generateDrinkTicketData());
//     }
//
//     // final userId = userRepository.userId();
//     //
//     // await ticketRepository.saveEventTickets(
//     //   userId: userId,
//     //   femalesTickets: femaleTicketCount,
//     //   maleTickets: maleTicketCount,
//     //   eventItem: eventItem,
//     // );
//   }
//
// }
