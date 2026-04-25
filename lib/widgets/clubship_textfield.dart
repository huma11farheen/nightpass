import 'package:clubship/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClubTextField extends StatefulWidget {
  const ClubTextField({
    super.key,
    this.icon,
    this.hintText,
    this.isPassword = false,
    this.isEmail = false,
    required this.onChanged,
    this.validator,
    this.errorText,
    this.maxlines = 1,
    this.type = TextInputType.multiline,
    this.initialText,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.controller,
    this.isNameField = false,
    this.autofocus = false,
  });

  final IconData? icon;
  final String? hintText;
  final bool? isPassword;
  final bool? isEmail;
  final Function(String) onChanged;
  final String Function(String?)? validator;
  final String? errorText;
  final int maxlines;
  final TextInputType type;
  final String? initialText;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool isNameField;
  final bool autofocus;

  @override
  State<ClubTextField> createState() => _ClubTextFieldState();
}

class _ClubTextFieldState extends State<ClubTextField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF1C1C22),

              //ColorPallete.backgroundcolor3.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused
                    ? ColorPallete.brightPink.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: _isFocused ? 1.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TextFormField(
                focusNode: _internalFocusNode,
                autofocus: widget.autofocus,
                controller: widget.controller,
                onTap: () {
                  widget.onTap?.call();
                },
                textAlignVertical: TextAlignVertical.center,
                initialValue: widget.controller == null ? widget.initialText : null,
                autofillHints: const [],
                maxLines: widget.maxlines,
                keyboardType: widget.type,
                validator: widget.validator,
                inputFormatters: widget.isNameField
                    ? [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ]
                    : null,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: ColorPallete.brightPink,
                onFieldSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                obscureText: widget.isPassword ?? false,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintMaxLines: 1,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: ColorPallete.brightPink,


                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
