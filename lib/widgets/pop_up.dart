import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'OK',
  VoidCallback? onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierColor: Brutal.bg.withValues(alpha: 0.85),
    builder: (ctx) => Dialog(
      backgroundColor: Brutal.elevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Brutal.yellow.withValues(alpha: 0.12),
              child: const Icon(Icons.check, color: Brutal.yellow, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Brutal.display(size: 22, color: Brutal.paper),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Brutal.body(size: 15, color: Brutal.dim),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: Brutal.magenta,
                alignment: Alignment.center,
                child: Text(confirmText,
                    style: Brutal.label(size: 12, color: Brutal.paper)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
