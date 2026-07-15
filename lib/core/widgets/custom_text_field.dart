import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? suffixIconPath;
  final Widget? prefixIcon;
  final String? prefixIconPath;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIconPath,
    this.prefixIconPath,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // When the parent supplies a suffixIcon it owns the visibility toggle
    // (e.g. driven by a cubit), so respect its `obscureText`. Otherwise the
    // field self-manages a built-in toggle for any obscured field.
    final hasExternalSuffix =
        widget.suffixIcon != null || widget.suffixIconPath != null;
    final isObscured = hasExternalSuffix ? widget.obscureText : _obscureText;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: isObscured,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.white16500,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIconPath != null
            ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(widget.prefixIconPath!),
        )
            : widget.prefixIcon,
        suffixIcon: hasExternalSuffix
            ? widget.suffixIconPath != null
            ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(widget.suffixIconPath!),
        )
            : widget.suffixIcon
            : widget.obscureText
            ? IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        )
            : null,
      ),
    );
  }
}
