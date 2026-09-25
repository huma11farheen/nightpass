import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.isEnabled = true,
    this.isLoading = false,
    this.icon,
    this.suffixIcon,
    this.isPersistentFooterButton = false,
  });

  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;
  final bool isLoading;
  final Widget? icon;
  final Widget? suffixIcon;
  final bool isPersistentFooterButton;

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && !isLoading;

    return Padding(
      padding: isPersistentFooterButton
          ? const EdgeInsets.fromLTRB(24, 0, 24, 16)
          : EdgeInsets.zero,
      child: GestureDetector(
        onTap: active ? onPressed : null,
        child: Container(
          height: 52,
          width: double.infinity,
          color: active ? backgroundColor : Brutal.elevated,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: suffixIcon != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 10)],
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Brutal.paper,
                      ),
                    )
                  : Text(
                      text,
                      style: Brutal.label(
                        size: 12,
                        color: active ? textColor : Brutal.mute,
                      ),
                    ),
              if (suffixIcon != null) ...[const Spacer(), suffixIcon!],
            ],
          ),
        ),
      ),
    );
  }

  /// Primary CTA — magenta fill, paper text.
  factory AppButton.primary({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    Widget? icon,
    Widget? suffixIcon,
    bool isPersistentFooterButton = false,
  }) =>
      AppButton._(
        text: text,
        onPressed: onPressed,
        backgroundColor: Brutal.magenta,
        textColor: Brutal.paper,
        isEnabled: isEnabled,
        isLoading: isLoading,
        icon: icon,
        suffixIcon: suffixIcon,
        isPersistentFooterButton: isPersistentFooterButton,
      );

  /// Secondary action — elevated fill, dim text.
  factory AppButton.secondary({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    Widget? icon,
    Widget? suffixIcon,
    bool isPersistentFooterButton = false,
  }) =>
      AppButton._(
        text: text,
        onPressed: onPressed,
        backgroundColor: Brutal.elevated,
        textColor: Brutal.dim,
        isEnabled: isEnabled,
        isLoading: isLoading,
        icon: icon,
        suffixIcon: suffixIcon,
        isPersistentFooterButton: isPersistentFooterButton,
      );

  /// Guestlist / special — yellow fill, dark text.
  factory AppButton.guestlist({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    bool isLoading = false,
    Widget? icon,
    bool isPersistentFooterButton = false,
  }) =>
      AppButton._(
        text: text,
        onPressed: onPressed,
        backgroundColor: Brutal.yellow,
        textColor: Brutal.bg,
        isEnabled: isEnabled,
        isLoading: isLoading,
        icon: icon,
        isPersistentFooterButton: isPersistentFooterButton,
      );
}
