import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

// ─── Base dialog ──────────────────────────────────────────────────────────────

class EVJDialog extends StatelessWidget {
  const EVJDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Brutal.elevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Brutal.display(size: 20, color: Brutal.paper)),
            const SizedBox(height: 12),
            Container(height: 1, color: Brutal.hairlineColor),
            const SizedBox(height: 16),
            Text(content, style: Brutal.body(size: 15, color: Brutal.dim)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
    required List<Widget> actions,
  }) =>
      showDialog<T>(
        context: context,
        builder: (_) => EVJDialog(title: title, content: content, actions: actions),
      );
}

// ─── Simple confirm / cancel dialog ──────────────────────────────────────────

class EVJSimpleDialog extends StatelessWidget {
  const EVJSimpleDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPositivePressed,
    required this.onNegativePressed,
    this.onPositiveButtonText = 'Yes',
    this.onNegativeButtonText = 'No',
  });

  final String title;
  final String content;
  final String? onPositiveButtonText;
  final String? onNegativeButtonText;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;

  @override
  Widget build(BuildContext context) {
    return EVJDialog(
      title: title,
      content: content,
      actions: [
        if (onNegativePressed != null)
          GestureDetector(
            onTap: onNegativePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Brutal.card,
              child: Text(
                onNegativeButtonText ?? 'No',
                style: Brutal.label(size: 11, color: Brutal.dim),
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (onPositivePressed != null)
          GestureDetector(
            onTap: onPositivePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Brutal.magenta,
              child: Text(
                onPositiveButtonText ?? 'Yes',
                style: Brutal.label(size: 11, color: Brutal.paper),
              ),
            ),
          ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    VoidCallback? onPositivePressed,
    VoidCallback? onNegativePressed,
    String onPositiveButtonText = 'Yes',
    String onNegativeButtonText = 'No',
  }) =>
      showDialog<bool>(
        context: context,
        builder: (_) => EVJSimpleDialog(
          title: title,
          content: content,
          onPositivePressed: onPositivePressed,
          onNegativePressed: onNegativePressed,
          onPositiveButtonText: onPositiveButtonText,
          onNegativeButtonText: onNegativeButtonText,
        ),
      );
}

// ─── Warning dialog (destructive action) ─────────────────────────────────────

class EVJWarningDialog extends StatelessWidget {
  const EVJWarningDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPositivePressed,
    required this.onNegativePressed,
    this.onPositiveButtonText = 'Yes',
    this.onNegativeButtonText = 'No',
  });

  final String title;
  final String content;
  final String? onPositiveButtonText;
  final String? onNegativeButtonText;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;

  @override
  Widget build(BuildContext context) {
    return EVJDialog(
      title: title,
      content: content,
      actions: [
        if (onNegativePressed != null)
          GestureDetector(
            onTap: onNegativePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Brutal.card,
              child: Text(
                onNegativeButtonText ?? 'No',
                style: Brutal.label(size: 11, color: Brutal.dim),
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (onPositivePressed != null)
          GestureDetector(
            onTap: onPositivePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.red,
              child: Text(
                onPositiveButtonText ?? 'Yes',
                style: Brutal.label(size: 11, color: Brutal.paper),
              ),
            ),
          ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    VoidCallback? onPositivePressed,
    VoidCallback? onNegativePressed,
    String onPositiveButtonText = 'Yes',
    String onNegativeButtonText = 'No',
  }) =>
      showDialog<bool>(
        context: context,
        builder: (_) => EVJWarningDialog(
          title: title,
          content: content,
          onPositivePressed: onPositivePressed,
          onNegativePressed: onNegativePressed,
          onPositiveButtonText: onPositiveButtonText,
          onNegativeButtonText: onNegativeButtonText,
        ),
      );
}
