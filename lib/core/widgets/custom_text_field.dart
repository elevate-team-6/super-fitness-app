import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
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
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
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
    final hasExternalSuffix = widget.suffixIcon != null;
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
      style: const TextStyle(color: AppColors.white),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: hasExternalSuffix
            ? widget.suffixIcon
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
