import 'dart:convert';

import 'package:clubship/colors.dart';
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
  bool _isAddingCard = false; // Prevent multiple simultaneous card additions

  // add-card UI state - commented out as related method is unused
  // bool _adding = false;
  // bool _cardComplete = false;
  // String? _setupClientSecret;

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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Remove Card',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to remove this card?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: ColorPallete.brightPink,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading state
      setState(() => isLoading = true);

      final response = await supabase.functions.invoke('detach-payment-method', body: {
        'payment_method_id': paymentMethodId,
      });

      // Check if the response indicates success
      debugPrint('Detach response: ${response.data}');

      // Refresh list
      await _fetchSavedCards();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error detaching card: $e');
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Unused method - commented out
  // Future<void> _openAddCardSheet() async {
  //   setState(() {
  //     _setupClientSecret = null;
  //     _cardComplete = false;
  //   });
  //
  //   // 1) Get SetupIntent client secret from your backend
  //   try {
  //     final resp = await supabase.functions.invoke('create-setup-intent');
  //     final data = (resp.data is String) ? jsonDecode(resp.data) : resp.data;
  //     _setupClientSecret = data['client_secret'] as String?;
  //   } catch (e) {
  //     debugPrint('SetupIntent error: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Could not start card setup')),
  //       );
  //     }
  //     return;
  //   }
  //
  //   if (!mounted || _setupClientSecret == null) return;
  //
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Theme.of(context).colorScheme.surface,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (ctx) {
  //       final viewInsets = MediaQuery.of(ctx).viewInsets;
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           left: 16,
  //           right: 16,
  //           bottom: viewInsets.bottom + 16,
  //           top: 16,
  //         ),
  //         child: StatefulBuilder(
  //           builder: (ctx, setSheetState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Text('Add a card', style: Theme.of(ctx).textTheme.titleLarge),
  //                 const SizedBox(height: 12),
  //                 CardField(
  //                   onCardChanged: (details) {
  //                     setSheetState(() {
  //                       _cardComplete = details?.complete == true;
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 16),
  //                 FilledButton(
  //                   onPressed: (!_cardComplete || _adding)
  //                       ? null
  //                       : () async {
  //                           setSheetState(() => _adding = true);
  //                           await _confirmSetupIntent(ctx);
  //                           setSheetState(() => _adding = false);
  //                         },
  //                   child: _adding
  //                       ? const SizedBox(
  //                           height: 20,
  //                           width: 20,
  //                           child: CircularProgressIndicator(strokeWidth: 2),
  //                         )
  //                       : const Text('Save card'),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 TextButton(
  //                   onPressed: _adding ? null : () => Navigator.pop(ctx),
  //                   child: const Text('Cancel'),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Unused method - commented out
  // Future<void> _confirmSetupIntent(BuildContext ctx) async {
  //   if (_setupClientSecret == null) return;
  //
  //   try {
  //     // 2) Confirm SetupIntent with the card the user entered
  //
  //     // If confirm succeeds, the payment method is now attached to the customer.
  //     if (mounted) Navigator.pop(ctx); // close sheet
  //     await _fetchSavedCards(); // refresh list
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Card added')),
  //       );
  //     }
  //   } on StripeException catch (e) {
  //     debugPrint('Stripe confirm error: ${e.error.localizedMessage}');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.error.localizedMessage ?? 'Stripe error')),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('Confirm setup error: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to save card')),
  //       );
  //     }
  //   }
  // }

  Future<void> addNewCard() async {
    final supabase = Supabase.instance.client;

    // Step 1: Create SetupIntent
    final res = await supabase.functions.invoke('create-setup-intent');
    final clientSecret = res.data['client_secret'];

    // Step 2: Confirm SetupIntent with card input
    await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ));

    // Step 3: Refresh saved cards list
    // await fetchSavedCards();
  }

  Future<void> _handleAddCard() async {
    // Prevent multiple simultaneous card additions
    if (_isAddingCard) return;

    setState(() {
      _isAddingCard = true;
    });

    try {
      final success = await StripePaymentHandler().addCardWithPaymentSheet();

      if (success) {
        // Card was successfully added, refresh the list
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
      if (mounted) {
        setState(() {
          _isAddingCard = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1625),
        title: Text(widget.isSelectionMode ? 'Select Card' : 'Saved Cards'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAddingCard ? null : _handleAddCard,
        backgroundColor: _isAddingCard ? Colors.grey : ColorPallete.brightPink,
        foregroundColor: Colors.white,
        icon: _isAddingCard
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isAddingCard ? 'Adding...' : 'Add card'),
      ),
      body: isLoading
          ? Skeletonizer(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2A2D3A).withOpacity(0.4),
                          ColorPallete.backgroundcolor2.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card, color: ColorPallete.brightPink),
                      title: Text('Visa •••• ${1234 + index}', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Expires ${12}/${2025 + index}', style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            )
          : savedCards.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2A2D3A).withOpacity(0.4),
                          ColorPallete.backgroundcolor2.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          size: 64,
                          color: ColorPallete.brightPink,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Saved Cards',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add a card to get started',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: savedCards.length,
                  itemBuilder: (context, index) {
                    final card = savedCards[index];
                    final isSelected = widget.isSelectionMode && widget.selectedCardId == card.id;

                    return GestureDetector(
                      onTap: widget.isSelectionMode
                          ? () {
                              // Return the selected card index and pop
                              Navigator.pop(context, index);
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [
                                    ColorPallete.brightPink.withOpacity(0.3),
                                    Colors.purple.withOpacity(0.3),
                                  ]
                                : [
                                    const Color(0xFF2A2D3A).withOpacity(0.4),
                                    ColorPallete.backgroundcolor2.withOpacity(0.3),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? ColorPallete.brightPink
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? ColorPallete.brightPink.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.3),
                              blurRadius: isSelected ? 16 : 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: const Icon(Icons.credit_card,
                              color: ColorPallete.brightPink),
                          title: Text(
                            '${card.brand} •••• ${card.last4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Expires ${card.expMonth}/${card.expYear}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: widget.isSelectionMode
                              ? (isSelected
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: ColorPallete.brightPink,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white38,
                                      size: 16,
                                    ))
                              : IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white70),
                                  onPressed: () => _detachCard(card.id),
                                ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
