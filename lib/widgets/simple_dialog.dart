import 'package:flutter/material.dart';

class EVJDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const EVJDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black,
            ),
      ),
      actions: actions,
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return EVJDialog(
          title: title,
          content: content,
          actions: actions,
        );
      },
    );
  }
}

class EVJSimpleDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? onPositiveButtonText;
  final String? onNegativeButtonText;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;

  const EVJSimpleDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPositivePressed,
    required this.onNegativePressed,
    this.onPositiveButtonText = "Yes",
    this.onNegativeButtonText = "No",
  });

  @override
  Widget build(BuildContext context) {
    return EVJDialog(
      title: title,
      content: content,
      actions: [
        onNegativePressed == null
            ? const SizedBox()
            : TextButton(
                onPressed: onNegativePressed,
                child: Text(
                  onNegativeButtonText ?? "No",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ),
        onPositivePressed == null
            ? const SizedBox()
            : TextButton(
                onPressed: onPositivePressed,
                child: Text(
                  onPositiveButtonText ?? "Yes",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
    String onPositiveButtonText = "Yes",
    String onNegativeButtonText = "No",
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return EVJSimpleDialog(
          title: title,
          content: content,
          onPositivePressed: onPositivePressed,
          onNegativePressed: onNegativePressed,
          onPositiveButtonText: onPositiveButtonText,
          onNegativeButtonText: onNegativeButtonText,
        );
      },
    );
  }
}

class EVJWarningDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? onPositiveButtonText;
  final String? onNegativeButtonText;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;

  const EVJWarningDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPositivePressed,
    required this.onNegativePressed,
    this.onPositiveButtonText = "Yes",
    this.onNegativeButtonText = "No",
  });

  @override
  Widget build(BuildContext context) {
    return EVJDialog(
      title: title,
      content: content,
      actions: [
        onNegativePressed == null
            ? const SizedBox()
            : TextButton(
                onPressed: onNegativePressed,
                child: Text(
                  onNegativeButtonText ?? "No",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ),
        onPositivePressed == null
            ? const SizedBox()
            : TextButton(
                onPressed: onPositivePressed,
                child: Text(
                  onPositiveButtonText ?? "Yes",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
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
    String onPositiveButtonText = "Yes",
    String onNegativeButtonText = "No",
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return EVJWarningDialog(
          title: title,
          content: content,
          onPositivePressed: onPositivePressed,
          onNegativePressed: onNegativePressed,
          onPositiveButtonText: onPositiveButtonText,
          onNegativeButtonText: onNegativeButtonText,
        );
      },
    );
  }
}
