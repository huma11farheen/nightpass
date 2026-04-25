import 'package:clubship/payment/payment_amount_provider.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddCustomAmountScreen extends ConsumerStatefulWidget {
  const AddCustomAmountScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddCustomAmountScreenState();
}

class _AddCustomAmountScreenState extends ConsumerState<AddCustomAmountScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Enter amount balance',
        ),
        const SizedBox(height: 100),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          cursorColor: Colors.orange,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.bottom,

          decoration: const InputDecoration(
            hintText: '¥0',
            hintStyle: TextStyle(color:Colors.white70)
          ),
          // onChanged: (value) {
          //   _amountController.value = TextEditingValue(
          //     text: '¥${value.replaceAll('¥', '')}',
          //     selection: TextSelection.collapsed(offset: value.length + 1),
          //   );
          // },
        ),
      ],
    ),
    persistentFooterButtons: [
      AppButton.primary(
        isPersistentFooterButton: true,
        text: 'Confirm',
        onPressed: () {
          final amount = _amountController.text.replaceAll('¥', '');
          ref
              .read(paymentAmountProvider.notifier)
              .setAmount(double.parse(amount).toInt());
          context.pop();
        },
      )
    ],
  );
}
