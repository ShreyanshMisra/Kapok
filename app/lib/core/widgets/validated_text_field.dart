import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable text field that shows inline validation after the first blur
/// (unfocus), a character counter when [maxLength] is provided, and a green
/// checkmark when the value is valid.
class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? suffixIcon;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.suffixIcon,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  bool _touched = false;
  String? _errorText;
  late FocusNode _focusNode;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_touched) {
      setState(() => _touched = true);
    }
    if (!_focusNode.hasFocus) {
      _validate();
    }
  }

  void _onTextChange() {
    if (_touched) _validate();
    widget.onChanged?.call(widget.controller.text);
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() => _errorText = widget.validator!(widget.controller.text));
    }
  }

  bool get _isValid => _touched && _errorText == null && widget.controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? effectiveSuffix;
    if (widget.obscureText) {
      effectiveSuffix = IconButton(
        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      );
    } else if (_isValid) {
      effectiveSuffix = Icon(Icons.check_circle, color: Colors.green.shade600, size: 20);
    } else {
      effectiveSuffix = widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText && !_showPassword,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: effectiveSuffix,
            errorText: _touched ? _errorText : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid
                    ? Colors.green.shade400
                    : (_touched && _errorText != null)
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline,
              ),
            ),
            counterText: widget.maxLength != null
                ? '${widget.controller.text.length}/${widget.maxLength}'
                : null,
            counterStyle: TextStyle(
              color: widget.maxLength != null &&
                      widget.controller.text.length > widget.maxLength!
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          validator: (v) {
            setState(() => _touched = true);
            _validate();
            return _errorText;
          },
          onChanged: (_) {
            if (_touched) _validate();
          },
        ),
      ],
    );
  }
}
