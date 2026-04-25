class StripeCardResponse {
  final String customerId;
  final String? paymentMethodId;
  final List<StripeCard> cards;

  StripeCardResponse({
    required this.customerId,
    required this.paymentMethodId,
    required this.cards,
  });

  factory StripeCardResponse.fromJson(Map<String, dynamic> json) {
    return StripeCardResponse(
      customerId: json['customer_id'] ?? '',
      paymentMethodId: json['payment_method_id'],
      cards: (json['data'] as List? ?? [])
          .map((e) => StripeCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StripeCard {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  StripeCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory StripeCard.fromJson(Map<String, dynamic> json) {
    final card = json['card'];
    return StripeCard(
      id: json['id'],
      brand: card['brand'],
      last4: card['last4'],
      expMonth: card['exp_month'],
      expYear: card['exp_year'],
    );
  }
}
