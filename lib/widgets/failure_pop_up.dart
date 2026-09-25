import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

Future<void> showFailureAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "Try Again",
  VoidCallback? onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierColor: Brutal.bg.withValues(alpha: 0.85),
    builder: (ctx) => Dialog(
      backgroundColor: Brutal.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withValues(alpha: 0.12),
              child: const Icon(Icons.close, color: Colors.red, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Brutal.display(size: 20, color: Brutal.paper),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Brutal.body(size: 16, color: Brutal.dim),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  onConfirm?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    confirmText,
                    style: Brutal.label(size: 13, color: Brutal.paper),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
