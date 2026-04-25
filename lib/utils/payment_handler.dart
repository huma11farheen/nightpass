// import 'dart:convert';
// import 'package:clubship/supabase/config.dart';
// import 'package:clubship/utils/helpers.dart';
// import 'package:clubship/utils/supabase_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// import '../supabase/supabase_client.dart';
//
// class StripePaymentHandler {
//   StripePaymentHandler() {
//     Stripe.publishableKey = Config.get('STRIPE_PUBLISHABLE_KEY');
//   }
//
//   Future<void> stripeMakePayment(int amount) async {
//     try {
//       final intent = await _createPaymentIntent(amount);
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//             appearance: PaymentSheetAppearance(
//               // colors: PaymentSheetAppearanceColors(
//               //     background: Colors.black,
//               //     primary: NomuColors.orange1,
//               //     primaryText: NomuColors.white100,
//               //     secondaryText: NomuColors.white100,
//               //     icon: NomuColors.grey25),
//             ),
//             customFlow: false,
//             customerId: intent.customerId,
//             customerEphemeralKeySecret: intent.ephemeralKey,
//             billingDetailsCollectionConfiguration:
//             const BillingDetailsCollectionConfiguration(
//                 attachDefaultsToPaymentMethod: true,
//                 address: AddressCollectionMode.never),
//             paymentIntentClientSecret: intent.clientSecret,
//             style: ThemeMode.dark,
//             primaryButtonLabel: formatCurrency(amount.toDouble()),
//             merchantDisplayName: 'Nightpass'),
//       );
//
//       await Stripe.instance.presentPaymentSheet();
//     } catch (e) {
//       if (e is StripeException && e.error.code == FailureCode.Canceled) {
//         print(e);
//         print('caught here');
//         // That's quite alright, just get on with it
//         return;
//       }
//       rethrow;
//     }
//   }
//
//   Future<_TopUpIntentResponse> _createPaymentIntent(int amount) async {
//     final response = await SupabaseFunctions.of(supabase)
//         .invoke('top-up-intent', body: {'amount': amount});
//
//     return _TopUpIntentResponse.fromJson(jsonDecode(response.data));
//   }
// }
//
// class _TopUpIntentResponse {
//   _TopUpIntentResponse._(
//       {required this.clientSecret,
//          this.customerId,
//          this.ephemeralKey});
//
//   factory _TopUpIntentResponse.fromJson(Map<String, dynamic> json) =>
//       _TopUpIntentResponse._(
//         clientSecret: json['client_secret'],
//         customerId: json['customer_id'],
//         ephemeralKey: json['ephemeral_key'],
//       );
//
//   final String clientSecret;
//   final String? customerId;
//   final String? ephemeralKey;
// }
