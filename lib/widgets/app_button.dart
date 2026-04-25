import 'package:clubship/colors.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
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
  final Gradient? gradient;
  final Gradient? disabledGradient;

  const AppButton({
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
    this.gradient,
    this.disabledGradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        (isEnabled && !isLoading) ? gradient : disabledGradient;

    return Padding(
      padding: isPersistentFooterButton
          ? const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0)
          : EdgeInsets.zero,
      child: SizedBox(
        height: height ?? 52,
        child: effectiveGradient != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius ?? 12),
                  boxShadow: (isEnabled && !isLoading)
                      ? [
                          BoxShadow(
                            color: ColorPallete.brightPink.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (isEnabled && !isLoading) ? onPressed : null,
                    borderRadius: BorderRadius.circular(borderRadius ?? 12),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: effectiveGradient,
                        borderRadius: BorderRadius.circular(borderRadius ?? 12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: (suffixIcon != null)
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          children: [
                            if (icon != null) icon!,
                            SizedBox(width: icon != null ? 12.0 : 0),
                            isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    text,
                                    style: TextStyle(
                                      color: textColor ?? Colors.white,
                                      fontSize: fontSize ?? 16,
                                      fontWeight: fontWeight ?? FontWeight.normal,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                            if (suffixIcon != null) const Spacer(),
                            if (suffixIcon != null) suffixIcon!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize ?? 16,
                    fontWeight: fontWeight ?? FontWeight.normal,
                  ),
                  disabledBackgroundColor:
                      disabledBackgroundColor ?? Colors.black54,
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 12),
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
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            text,
                            style: TextStyle(
                              color: textColor,
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

  factory AppButton.guestlist({
    required String text,
    required Function() onPressed,
    bool isEnabled = true,
    Widget? icon,
    isLoading = false,
    bool isPersistentFooterButton = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      textColor: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      borderRadius: 16,
      isEnabled: isEnabled,
      backgroundColor: ColorPallete.brightPink,
      disabledBackgroundColor: ColorPallete.brightPink.withOpacity(0.5),
      icon: icon,
      isLoading: isLoading,
      isPersistentFooterButton: isPersistentFooterButton,
      gradient: LinearGradient(
        colors: [
          ColorPallete.brightPink,
          const Color(0xFFE91E63),
        ],
      ),
      disabledGradient: LinearGradient(
        colors: [
          ColorPallete.brightPink.withOpacity(0.5),
          const Color(0xFFE91E63).withOpacity(0.5),
        ],
      ),
    );
  }

  factory AppButton.primary({
    required String text,
    required Function() onPressed,
    bool isEnabled = true,
    Widget? icon,
    isLoading = false,
    bool isPersistentFooterButton = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      textColor: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      borderRadius: 16,
      isEnabled: isEnabled,
      backgroundColor: ColorPallete.brightPink,
      disabledBackgroundColor: ColorPallete.brightPink.withOpacity(0.5),
      icon: icon,
      isLoading: isLoading,
      isPersistentFooterButton: isPersistentFooterButton,
      gradient: LinearGradient(
        colors: [
          ColorPallete.brightPink,
          const Color(0xFFE91E63),
        ],
      ),
      disabledGradient: LinearGradient(
        colors: [
          ColorPallete.brightPink.withOpacity(0.5),
          const Color(0xFFE91E63).withOpacity(0.5),
        ],
      ),
    );
  }

  factory AppButton.secondary({
    required String text,
    required Function() onPressed,
    bool isEnabled = true,
    Widget? icon,
    isLoading = false,
    bool isPersistentFooterButton = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      textColor: Colors.grey,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      borderRadius: 10,
      isEnabled: isEnabled,
      backgroundColor: ColorPallete.grey10,
      disabledBackgroundColor: Colors.black54,
      icon: icon,
      isLoading: isLoading,
      isPersistentFooterButton: isPersistentFooterButton,
    );
  }
}
