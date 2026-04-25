import 'package:clubship/colors.dart';
import 'package:clubship/payment/payment_amount_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';


class UserWalletScreen extends ConsumerStatefulWidget {
  const UserWalletScreen({super.key});

  @override
  ConsumerState<UserWalletScreen> createState() => _UserWalletScreenState();
}

class _UserWalletScreenState extends ConsumerState<UserWalletScreen> {
  int _selectedIndex = -1;
  int paymentAmount = 0;
  bool isLoading = false;

  // Future<void> _updateUserCredits({required int creditsBefore}) async {
  //   // Within a given timeout, try to refresh the user credits until updated
  //   final timeout = DateTime.now().add(const Duration(seconds: 5));
  //   while (DateTime.now().isBefore(timeout)) {
  //     await Future.delayed(const Duration(seconds: 1));
  //     final newValue = await ref.refresh(userCreditsProvider.future);
  //     if (newValue != creditsBefore) {
  //       _resetPayment();
  //       return;
  //     }
  //   }
  //   _resetPayment();
  // }

  void _resetPayment() {
    setState(() {
      _selectedIndex = -1;
    });
    ref.read(paymentAmountProvider.notifier).setAmount(0);
  }

  Widget _buildButton(int index, int amount, {String? label}) {
    BorderRadius borderRadius;

    switch (index) {
      case 0:
        borderRadius = const BorderRadius.only(topLeft: Radius.circular(2));
        break;
      case 1:
        borderRadius = const BorderRadius.only(topRight: Radius.circular(2));
        break;
      case 2:
        borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(2));
        break;
      case 3:
        borderRadius = const BorderRadius.only(bottomRight: Radius.circular(2));
        break;
      default:
        borderRadius = BorderRadius.circular(0);
    }

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final currentAmount = ref.watch(paymentAmountProvider);

        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: GestureDetector(
            onTap: () {
              if (index == 3) {
                context.push(Routes.addCustomAmount);
                if (currentAmount != 0) {
                  setState(() {
                    _selectedIndex = 3;
                  });
                } else {
                  setState(() {
                    _selectedIndex = -1;
                  });
                }
              } else {
                setState(() {
                  _selectedIndex = index;
                  ref.read(paymentAmountProvider.notifier).setAmount(amount);
                });
              }
            },
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                height: 56,
                width: (MediaQuery.of(context).size.width / 2) - 26,
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ?  ColorPallete.cardColor
                      : Colors.white12,
                ),
                child: Center(
                  child: Text(
                    style: const TextStyle(fontSize: 18),
                    label ?? formatCurrency(amount.toDouble()),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentAmount = ref.watch(paymentAmountProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                const Text(
                  'Your balance',
                  style: TextStyle(fontSize: 26),
                ),
                // Uncomment when userCreditsProvider is active
                // Consumer(
                //   builder: (context, ref, _) =>
                //       ref.watch(userCreditsProvider).when(
                //         skipLoadingOnRefresh: false,
                //         data: (userCredits) => Text(
                //           style: const TextStyle(fontSize: 56),
                //           formatCurrency(userCredits.toDouble()),
                //         ),
                //         loading: () => Skeletonizer(
                //           child: Text(
                //             formatCurrency(25000.0),
                //             style: const TextStyle(fontSize: 56),
                //           ),
                //         ),
                //         error: (e, st) => const Text('Error loading balance'),
                //       ),
                // ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Deposit amount',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(paymentAmount.toDouble()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(0, 500),
              _buildButton(1, 1000),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(2, 3000),
              _buildButton(3, 0, label: 'Other'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      persistentFooterButtons: [
        Column(
          children: [
            // AppButton.primary(
            //   isEnabled:paymentAmount>0,
            //   isPersistentFooterButton: true,
            //   text: isLoading ? 'Please wait' : 'Charge',
            //   onPressed: () async {
            //     setState(() {
            //       isLoading = true;
            //     });
            //     try {
            //       final currentCredits =
            //           ref.read(userCreditsProvider).value ?? 0;
            //      // await StripePaymentHandler().stripeMakePayment(paymentAmount);
            //       _updateUserCredits(creditsBefore: currentCredits);
            //     } catch (exception) {
            //       if (context.mounted) {
            //         context.showSnackbar(message: exception.toString());
            //       }
            //       _resetPayment();
            //     } finally {
            //       setState(() {
            //         isLoading = false;
            //       });
            //     }
            //   },
            // ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () => context.push(Routes.transactionHistory),
                  child: const Text(
                    'Transaction History',
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
