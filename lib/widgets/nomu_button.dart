import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NomuButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final double? height;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool isEnabled;
  final Color backgroundColor;
  final Color? disabledBackgroundColor;
  final Widget? icon;
  final bool isLoading;
  final bool isPersistentFooterButton;
  final Widget? suffixIcon;

  const NomuButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.isEnabled = true,
    required this.backgroundColor,
    this.disabledBackgroundColor,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isPersistentFooterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isPersistentFooterButton
          ? const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0)
          : EdgeInsets.zero,
      child: SizedBox(
        height: height ?? 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                disabledBackgroundColor ?? Colors.black,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 100),
            ),
          ),
          onPressed: (isEnabled && !isLoading) ? onPressed : null,
          child: Row(
            mainAxisAlignment: (suffixIcon != null)
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (icon != null) icon!,
              SizedBox(width: icon != null ? 12.0 : 0),
              isLoading
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator())
                  : Text(
                      text,
                      style: GoogleFonts.ibmPlexSansJp(
                        fontSize: fontSize,
                        color: textColor,
                        fontWeight: fontWeight,
                      ),
                    ),
              if (suffixIcon != null) const Spacer(),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
      ),
    );
  }

  factory NomuButton.primary({
    required String text,
    required Function() onPressed,
    bool isEnabled = true,
    Widget? icon,
    isLoading = false,
    bool isPersistentFooterButton = false,
  }) {
    return NomuButton(
      text: text,
      onPressed: onPressed,
      textColor: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      isEnabled: isEnabled,
      backgroundColor: Colors.purpleAccent,
      disabledBackgroundColor: Colors.purpleAccent.withValues(alpha: 0.8),
      icon: icon,
      isLoading: isLoading,
      isPersistentFooterButton: isPersistentFooterButton,
    );
  }

  factory NomuButton.secondary({
    required String text,
    required Function() onPressed,
    bool isEnabled = true,
    Widget? icon,
    isLoading = false,
    bool isPersistentFooterButton = false,
  }) {
    return NomuButton(
      text: text,
      onPressed: onPressed,
      textColor: Colors.grey,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      isEnabled: isEnabled,
      backgroundColor: Colors.black54,
      disabledBackgroundColor:  Colors.black54,
      icon: icon,
      isLoading: isLoading,
      isPersistentFooterButton: isPersistentFooterButton,
    );
  }
}
