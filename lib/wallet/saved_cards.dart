import 'package:clubship/widgets/back_button.dart';
import 'dart:convert';

import 'package:clubship/design/brutal.dart';
import 'package:clubship/payment/stripe_payment_handler.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/wallet/models/saved_card_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SavedCardsPage extends StatefulWidget {
  final bool isSelectionMode;
  final String? selectedCardId;

  const SavedCardsPage({
    super.key,
    this.isSelectionMode = false,
    this.selectedCardId,
  });

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  List<StripeCard> savedCards = [];
  bool isLoading = true;
  bool _isAddingCard = false;

  @override
  void initState() {
    super.initState();
    _fetchSavedCards();
  }

  Future<void> _fetchSavedCards() async {
    try {
      setState(() => isLoading = true);
      final response = await supabase.functions.invoke('get-saved-cards');
      final decoded = jsonDecode(response.data);
      final cardResponse = StripeCardResponse.fromJson(decoded);

      setState(() {
        savedCards = cardResponse.cards;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load saved cards')),
      );
    }
  }

  Future<void> _detachCard(String paymentMethodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Brutal.elevated,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('REMOVE CARD', style: Brutal.label(size: 12, color: Brutal.paper)),
        content: Text(
          'Are you sure you want to remove this card?',
          style: Brutal.body(size: 15, color: Brutal.dim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: Brutal.label(size: 11, color: Brutal.mute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: Brutal.label(size: 11, color: Brutal.magenta)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => isLoading = true);
      await supabase.functions.invoke('detach-payment-method', body: {
        'payment_method_id': paymentMethodId,
      });
      await _fetchSavedCards();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card removed successfully')),
      );
    } catch (e) {
      debugPrint('Error detaching card: $e');
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove card: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> addNewCard() async {
    final supabase = Supabase.instance.client;
    final res = await supabase.functions.invoke('create-setup-intent');
    final clientSecret = res.data['client_secret'];
    await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ));
  }

  Future<void> _handleAddCard() async {
    if (_isAddingCard) return;
    setState(() => _isAddingCard = true);

    try {
      final success = await StripePaymentHandler().addCardWithPaymentSheet();
      if (success) {
        await _fetchSavedCards();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error adding card: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add card')),
      );
    } finally {
      if (mounted) setState(() => _isAddingCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brutal.bg,
      appBar: AppBar(
        backgroundColor: Brutal.bg,
        elevation: 0,
        leading: const AppBackButton(forAppBar: true),
        title: Text(
          widget.isSelectionMode ? 'Select Card' : 'Wallet & Cards',
          style: Brutal.display(size: 20, color: Brutal.paper),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Brutal.hairlineColor),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _isAddingCard ? null : _handleAddCard,
        child: Container(
          decoration: BoxDecoration(
            color: _isAddingCard ? Brutal.hover : Brutal.magenta,
            border: Border.all(color: _isAddingCard ? Brutal.hairlineColor : Brutal.magenta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isAddingCard
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Brutal.paper,
                      ),
                    )
                  : const Icon(Icons.add, color: Brutal.paper, size: 18),
              const SizedBox(width: 8),
              Text(
                _isAddingCard ? 'Adding...' : 'Add Card',
                style: Brutal.label(size: 12, color: Brutal.paper),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Skeletonizer(
              effect: const ShimmerEffect(
                baseColor: Brutal.elevated,
                highlightColor: Brutal.hover,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  color: Brutal.elevated,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(width: 36, height: 36, color: Brutal.hover),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120, height: 14, color: Brutal.hover),
                            const SizedBox(height: 8),
                            Container(width: 80, height: 10, color: Brutal.hover),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : savedCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Brutal.elevated,
                        child: const Icon(
                          Icons.credit_card_outlined,
                          size: 36,
                          color: Brutal.mute,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('No Saved Cards', style: Brutal.display(size: 22, color: Brutal.paper)),
                      const SizedBox(height: 8),
                      Text('Tap + Add Card to get started', style: Brutal.body(size: 15, color: Brutal.mute)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: savedCards.length,
                  itemBuilder: (context, index) {
                    final card = savedCards[index];
                    final isSelected =
                        widget.isSelectionMode && widget.selectedCardId == card.id;

                    return GestureDetector(
                      onTap: widget.isSelectionMode
                          ? () => Navigator.pop(context, index)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Brutal.bg : Brutal.elevated,
                          border: isSelected
                              ? Border.all(color: Brutal.magenta, width: 2)
                              : Border.all(color: Brutal.hairlineColor),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              color: Brutal.card,
                              child: Icon(
                                Icons.credit_card,
                                color: isSelected ? Brutal.magenta : Brutal.cyan,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${card.brand.toUpperCase()} ···· ${card.last4}',
                                    style: Brutal.body(size: 16, color: Brutal.paper),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Expires ${card.expMonth}/${card.expYear}',
                                    style: Brutal.label(size: 10, color: Brutal.mute),
                                  ),
                                ],
                              ),
                            ),
                            widget.isSelectionMode
                                ? (isSelected
                                    ? const Icon(Icons.check, color: Brutal.magenta, size: 18)
                                    : const Icon(Icons.arrow_forward_ios, color: Brutal.mute, size: 14))
                                : GestureDetector(
                                    onTap: () => _detachCard(card.id),
                                    child: const Icon(Icons.delete_outline, color: Brutal.mute, size: 18),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
