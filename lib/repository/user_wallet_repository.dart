import 'dart:convert';

import 'package:clubship/data/supabase_models/user_wallet.dart';
import 'package:clubship/data/supabase_models/user_wallet_event.dart';
import 'package:clubship/wallet/models/saved_card_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserWalletRepository {
  UserWalletRepository(this.supabase);

  final SupabaseClient supabase;

  Future<int> getCredits() async {
    final result = await supabase
        .from(UserWallet.modelName)
        .select()
        .eq('id', supabase.auth.currentSession?.user.id ?? '')
        .maybeSingle()
        .withConverter(
            (data) => data != null ? UserWallet.fromJson(data).credits : 0);
    return result ?? 0;
  }

  Future<List<StripeCard>> fetchSavedCards() async {
    final response = await supabase.functions.invoke('get-saved-cards');
    final decoded = jsonDecode(response.data);
    final cardResponse = StripeCardResponse.fromJson(decoded);
    return cardResponse.cards;
  }

  Future<void> confirmSetupIntent(String clientSecret) async {
    await Stripe.instance.confirmSetupIntent(
      paymentIntentClientSecret: clientSecret,
      params: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );
  }

  Future<void> addNewCard() async {
    final clientSecret = await createSetupIntent();
    if (clientSecret == null) throw Exception('Failed to create SetupIntent');

    await confirmSetupIntent(clientSecret);
  }

  Future<String?> createSetupIntent() async {
    final resp = await supabase.functions.invoke('create-setup-intent');
    final data = (resp.data is String) ? jsonDecode(resp.data) : resp.data;
    return data['client_secret'] as String?;
  }

  Future<void> detachCard(String paymentMethodId) async {
    await supabase.functions.invoke('detach-payment-method', body: {
      'payment_method_id': paymentMethodId,
    });
  }

  Future<void> addCredits(int amount) async {
    final currentCredits = await getCredits();
    final updatedCredits = currentCredits + amount;
    final response = await supabase
        .from(UserWallet.modelName)
        .upsert({'credits': updatedCredits});
    if (response.error != null) {
      throw Exception('Failed to add credits: ${response.error!.message}');
    }
  }

  Future<void> deleteCredits(int credits) async {
    try {
      await supabase.from(UserWallet.modelName).upsert({'credits': credits});
    } catch (e) {
      //logException(e, st);
    }
  }

  Future<List<UserWalletEvent>> getUserWalletEvents() async {
    final id = supabase.auth.currentSession?.user.id;
    if (id == null) {
      throw Exception('No user id found');
    }
    try {
      return await supabase
          .from(UserWalletEvent.modelName)
          .select('*')
          .eq('user_id', id)
          .neq('reason', 'cancel_order')
          .withConverter(
              (data) => data.map((e) => UserWalletEvent.fromJson(e)).toList());
    } catch (e) {
      throw Exception(e);
    }
  }
}
