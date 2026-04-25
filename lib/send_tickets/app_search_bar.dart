import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NomuSearchBar extends ConsumerWidget {
  const NomuSearchBar({
    super.key,
    required this.placeholderText,
    required this.onTap,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.iconColor = Colors.grey,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
  });

  final String placeholderText;
  final VoidCallback onTap;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Color? iconColor;
  final bool? enabled;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color fillAndBorderColor = Colors.grey[800]!;

    return SizedBox(
      height: 44,
      width: 280,
      child: TextFormField(
        enableSuggestions: false,
        enabled: enabled,
        readOnly: readOnly,
        controller: controller,
        focusNode: focusNode,
        onTap: onTap,
        onFieldSubmitted: (value) {
          onSubmitted?.call(value);
        },
        autofocus: autofocus,
        cursorHeight: 20,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
        decoration: InputDecoration(
          isDense: true,
          hintText: placeholderText,
          hintStyle: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: fillAndBorderColor),
            borderRadius: BorderRadius.circular(24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: fillAndBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fillAndBorderColor),
            borderRadius: BorderRadius.circular(24),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fillAndBorderColor),
            borderRadius: BorderRadius.circular(24),
          ),

          // ✅ Correct way → keeps icon + text aligned
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: iconColor,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 30, // smaller than default 48 → reduces gap
            minHeight: 20,
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
