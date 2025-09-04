import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final bool readOnly;
  final void Function()? onTap;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final bool expands;
  final int? maxLength;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final bool? showCursor;
  final TextDirection? textDirection;
  final TextEditingController? textController;
  final String? restorationId; // This is nullable by design for restoration purposes
  final bool enableInteractiveSelection;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final String obscuringCharacter;
  final bool autovalidate;
  final bool? enableIMEPersonalizedLearning;
  final bool enablePersonalizedLearning;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.readOnly = false,
    this.onTap,
    this.decoration,
    this.contentPadding,
    this.style,
    this.expands = false,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.errorText,
    this.helperText,
    this.counterText,
    this.filled = false,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.showCursor,
    this.textDirection,
    this.textController,
    this.restorationId,
    this.enableInteractiveSelection = true,
    this.scrollController,
    this.scrollPhysics,
    this.obscuringCharacter = '•', // Default bullet point for password fields
    this.autovalidate = false,
    this.enableIMEPersonalizedLearning,
    this.enablePersonalizedLearning = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        helperText: helperText,
        counterText: counterText,
        filled: filled,
        fillColor: fillColor,
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      initialValue: initialValue,
      readOnly: readOnly,
      onTap: onTap,
      style: style,
      expands: expands,
      maxLength: maxLength,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      showCursor: showCursor,
      textDirection: textDirection,
      restorationId: restorationId ?? '', // Provide empty string as fallback
      enableInteractiveSelection: enableInteractiveSelection,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      obscuringCharacter: obscuringCharacter, // Already non-null with default value
      autovalidateMode: autovalidate ? AutovalidateMode.always : null,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning ?? enablePersonalizedLearning,
    );
  }
}
