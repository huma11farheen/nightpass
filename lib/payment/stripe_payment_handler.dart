import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/supabase/config.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/supabase_functions.dart';

enum PurchaseStatus {
  success,
  cancelled,
}

class StripePaymentHandler {

  StripePaymentHandler() {
    Stripe.publishableKey = Config.get('STRIPE_PUBLISHABLE_KEY');
  }

  /// Check if Apple Pay is available on this device
  /// Note: PaymentSheet will automatically show/hide Apple Pay based on device capabilities
  static bool canUseApplePay() {
    // Apple Pay is only available on iOS
    return Platform.isIOS;
  }

  /// Check if Google Pay is available on this device
  /// Note: PaymentSheet will automatically show/hide Google Pay based on device capabilities
  static bool canUseGooglePay() {
    // Google Pay is only available on Android
    return Platform.isAndroid;
  }

  Future<PurchaseStatus> stripeMakePayment(double amount) async {
    try {
      final setup = await _getSetupInfo();

      // if (setup.paymentMethodId != null && setup.customerId != null) {
      //   print('debug');
      //   print(setup.paymentMethodId);
      //   print(setup.customerId);
      //   await _chargeSavedCard(amount, setup.customerId!, setup.paymentMethodId!);
      //   return PurchaseStatus.success;
      // }

      final intent = await _createPaymentIntent(amount);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.black,
              primary: ColorPallete.brightPink,
              primaryText: Colors.white,
              secondaryText: Colors.white,
              icon: Colors.grey,
            ),


          ),
          customerId: intent.customerId,
          customerEphemeralKeySecret: intent.ephemeralKey,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            attachDefaultsToPaymentMethod: true,
            address: AddressCollectionMode.never,
          ),
          paymentIntentClientSecret: intent.clientSecret,
          style: ThemeMode.dark,
          primaryButtonLabel: 'Pay Now ${formatCurrency(amount.toDouble())}',
          merchantDisplayName: 'Nightpass',
          // Enable Google Pay only (Apple Pay disabled - requires merchant identifier)
          googlePay: Platform.isAndroid ? const PaymentSheetGooglePay(
            merchantCountryCode: 'JP',
            currencyCode: 'JPY',
            testEnv: true, // Set to false in production
          ) : null,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return PurchaseStatus.success;
    } catch (e) {
      print('Payment error: $e');
      if (e is StripeException && e.error.code == FailureCode.Canceled) {
        return PurchaseStatus.cancelled;
      }
      rethrow;
    }
  }

  /// Saves a new card to the customer using Stripe PaymentSheet + SetupIntent.
  /// Returns true if a card was added.
  Future<bool> addCardWithPaymentSheet() async {
    try {
      // 1) Ask your Edge Function for a SetupIntent
      final res = await SupabaseFunctions.of(supabase).invoke('save-card-intend');

      final Map<String, dynamic> data =
      res.data is String ? jsonDecode(res.data as String)
          : (res.data as Map<String, dynamic>);

      final clientSecret = data['client_secret'] as String;
      // If you also return customer id, use it (recommended):
      final customerId = (data['customer_id'] as String?) ?? (await _getSetupInfo()).customerId;

      if (customerId == null) {
        throw Exception('Missing customer_id. Ensure your Edge Function returns it or user has a Stripe customer.');
      }

      // 2) Initialize PaymentSheet with the SetupIntent
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          customerId: customerId,
          merchantDisplayName: 'Nightpass',
          style: ThemeMode.dark,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.never,
            email: CollectionMode.never,
            phone: CollectionMode.never,
            address: AddressCollectionMode.never,
            attachDefaultsToPaymentMethod: true,
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.black,
              primary: ColorPallete.brightPink,
              primaryText: Colors.white,
              secondaryText: Colors.white,
              icon: Colors.grey,
            ),
          ),
          // Enable Google Pay only for adding cards (Apple Pay disabled - requires merchant identifier)
          googlePay: Platform.isAndroid ? const PaymentSheetGooglePay(
            merchantCountryCode: 'JP',
            currencyCode: 'JPY',
            testEnv: true, // Set to false in production
          ) : null,
        ),
      );

      // 3) Present PaymentSheet — user enters card; on success, card is attached
      await Stripe.instance.presentPaymentSheet();

      // 4) (Optional) refresh your saved cards list wherever you show it
      return true;
    } on StripeException catch (e) {
      // User cancelled or 3DS failed, etc.
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('addCardWithPaymentSheet error: $e');
      rethrow; // or return false
    }
  }


  Future<void> _saveCardForFuture(String customerId) async {
    final setupIntent = await _createSetupIntent(customerId);
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: setupIntent.clientSecret,
        merchantDisplayName: 'Nightpass',
        customerId: customerId,
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            background: Colors.black,
            primary: ColorPallete.brightPink,
            primaryText: Colors.white,
            secondaryText: Colors.white,
            icon: Colors.grey,
          ),
        ),
        // Enable Google Pay only for saving cards (Apple Pay disabled - requires merchant identifier)
        googlePay: Platform.isAndroid ? const PaymentSheetGooglePay(
          merchantCountryCode: 'JP',
          currencyCode: 'JPY',
          testEnv: true, // Set to false in production
        ) : null,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  Future<void> _chargeSavedCard(
      double amount, String customerId, String paymentMethodId) async {
    final body = {
      'amount': amount,
      'customer_id': customerId,
      'payment_method_id': paymentMethodId,
    };
    await SupabaseFunctions.of(supabase)
        .invoke('charge-saved-cards', body: body);
  }

  Future<_TopUpIntentResponse> _createPaymentIntent(double amount) async {
    final response = await SupabaseFunctions.of(supabase)
        .invoke('top-up-intent', body: {'amount': amount});
    print(response.data);
    print('topup');
    return _TopUpIntentResponse.fromJson(jsonDecode(response.data));
  }

  Future<_SetupIntentResponse> _createSetupIntent(String customerId) async {
    final response = await SupabaseFunctions.of(supabase).invoke(
      'save-card-intend',
      body: {'customer_id': customerId},
    );
    return _SetupIntentResponse.fromJson(jsonDecode(response.data));
  }

  Future<_SavedCardSetup> _getSetupInfo() async {
    final response = await SupabaseFunctions.of(supabase)
        .invoke('get-saved-cards', body: {});
    print('check exsitimng');
    print(jsonDecode(response.data));
    return _SavedCardSetup.fromJson(jsonDecode(response.data));
  }
}

class _TopUpIntentResponse {
  _TopUpIntentResponse._({
    required this.clientSecret,
    required this.customerId,
    required this.ephemeralKey,
  });

  factory _TopUpIntentResponse.fromJson(Map<String, dynamic> json) =>
      _TopUpIntentResponse._(
        clientSecret: json['client_secret'],
        customerId: json['customer_id'],
        ephemeralKey: json['ephemeral_key'],
      );

  final String clientSecret;
  final String customerId;
  final String ephemeralKey;
}

class _SetupIntentResponse {
  _SetupIntentResponse({required this.clientSecret});

  factory _SetupIntentResponse.fromJson(Map<String, dynamic> json) =>
      _SetupIntentResponse(clientSecret: json['client_secret']);
  final String clientSecret;
}

class _SavedCardSetup {
  _SavedCardSetup({required this.customerId, this.paymentMethodId});

  factory _SavedCardSetup.fromJson(Map<String, dynamic> json) =>
      _SavedCardSetup(
        customerId: json['customer_id'],
        paymentMethodId: json['payment_method_id'],
      );

  final String? customerId;
  final String? paymentMethodId;
}
