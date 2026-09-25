import 'package:clubship/design/brutal.dart';
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Brutal.elevated,
            border: Border.all(
              color: _isFocused ? Brutal.magenta : Brutal.hairlineColor,
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            focusNode: _internalFocusNode,
            autofocus: widget.autofocus,
            controller: widget.controller,
            onTap: widget.onTap,
            textAlignVertical: TextAlignVertical.center,
            initialValue:
                widget.controller == null ? widget.initialText : null,
            autofillHints: const [],
            maxLines: widget.maxlines,
            keyboardType: widget.type,
            validator: widget.validator,
            inputFormatters: widget.isNameField
                ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
                : null,
            style: Brutal.body(size: 17, color: Brutal.paper),
            cursorColor: Brutal.magenta,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            obscureText: widget.isPassword ?? false,
            decoration: InputDecoration(
              filled: false,
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintMaxLines: 1,
              hintText: widget.hintText,
              hintStyle: Brutal.body(size: 17, color: Brutal.mute),
              prefixIcon: widget.icon != null
                  ? Icon(widget.icon, color: Brutal.mute, size: 18)
                  : null,
            ),
          ),
        ),

        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              widget.errorText!,
              style: Brutal.label(size: 11, color: Brutal.magenta),
            ),
          ),
      ],
    );
  }
}
