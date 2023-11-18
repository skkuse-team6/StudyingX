import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveTextField extends StatefulWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.autofillHints,
    this.keyboardType,
    this.textInputAction,
    required this.focusOrder,
    this.validator,
  });

  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final NumericFocusOrder focusOrder;
  final String? Function(String?)? validator;

  @override
  State<StatefulWidget> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  bool obscureText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool cupertino = theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    TextInputType? keyboardType = widget.keyboardType;

    if (cupertino) {
      return Row(
        children: [
          Expanded(
            child: FocusTraversalOrder(
              order: widget.focusOrder,
              child: CupertinoTextFormFieldRow(
                controller: widget.controller,
                autofillHints: widget.autofillHints,
                keyboardType: keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: obscureText,
                cursorColor: Colors.lightGreen,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.lightGreen.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                style: const TextStyle(color: Colors.lightGreen),
                validator: widget.validator,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    } else {
      return FocusTraversalOrder(
        order: widget.focusOrder,
        child: TextFormField(
          controller: widget.controller,
          autofillHints: widget.autofillHints,
          keyboardType: keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: obscureText,
          validator: widget.validator,
          cursorColor: Colors.lightGreen,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.lightGreen.withOpacity(0.5)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.lightGreen.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreen),
            ),
            hoverColor: Colors.lightGreen,
          ),
        ),
      );
    }
  }
}
